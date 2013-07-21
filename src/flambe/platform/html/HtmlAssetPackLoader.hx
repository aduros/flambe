//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import haxe.Http;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.util.Assert;
import flambe.util.Promise;
import flambe.util.Signal0;
import flambe.util.Signal1;

class HtmlAssetPackLoader extends BasicAssetPackLoader
{
    public function new (platform :HtmlPlatform, manifest :Manifest)
    {
        super(platform, manifest);
    }

    override private function loadEntry (url :String, entry :AssetEntry)
    {
        switch (entry.format) {
        case WEBP, JXR, PNG, JPG, GIF:
            var image = Browser.document.createImageElement();
            var events = new EventGroup();

            events.addDisposingListener(image, "load", function (_) {
#if debug
                if (image.width > 1024 || image.height > 1024) {
                    Log.warn("Images larger than 1024px on a side will prevent GPU acceleration" +
                        " on some platforms (iOS)", ["url", url,
                        "width", image.width, "height", image.height]);
                }
#end
                if (supportsBlob()) {
                    // Reclaim memory previously allocated by createObjectURL
                    _URL.revokeObjectURL(image.src);
                }

                var texture = _platform.getRenderer().createTexture(image);
                if (texture != null) {
                    handleLoad(entry, texture);
                } else {
                    handleTextureError(entry);
                }
            });
            events.addDisposingListener(image, "error", function (_) {
                handleError(entry, "Failed to load image");
            });

            // If this browser supports Blob, load the image data over XHR to benefit from progress
            // events, otherwise just set the src directly
            if (supportsBlob()) {
                downloadBlob(url, entry, function (blob) {
                    image.src = _URL.createObjectURL(blob);
                });
            } else {
                image.src = url;
            }

        case DDS, PVR, PKM:
            downloadArrayBuffer(url, entry, function (buffer) {
                // FIXME(bruno): Convert buffer to a Bytes and pass it along
                var texture = _platform.getRenderer().createCompressedTexture(entry.format, null);
                if (texture != null) {
                    handleLoad(entry, texture);
                } else {
                    handleTextureError(entry);
                }
            });

        case MP3, M4A, OPUS, OGG, WAV:
            // If we made it this far, we definitely support audio and can play this asset
            if (WebAudioSound.supported) {
                downloadArrayBuffer(url, entry, function (buffer) {
                    WebAudioSound.ctx.decodeAudioData(buffer, function (decoded) {
                        handleLoad(entry, new WebAudioSound(decoded));
                    }, function () {
                        // Happens in iOS 6 beta for some sounds that should be able to play. It
                        // seems that monochannel audio will always fail, try converting to stereo.
                        // Since this happens unpredictably, continue with a DummySound rather than
                        // rejecting the entire asset pack.
                        Log.warn("Couldn't decode Web Audio, ignoring this asset", ["url", url]);
                        handleLoad(entry, DummySound.getInstance());
                    });
                });

            } else {
                var audio = Browser.document.createAudioElement();
                audio.preload = "auto"; // Hint that we want to preload the entire file

                // Maintain a hard reference to the audio during loading to prevent GC on some
                // browsers
                var ref = ++_mediaRefCount;
                if (_mediaElements == null) {
                    _mediaElements = new Map<Int,Dynamic>();
                }
                _mediaElements.set(ref, audio);

                var events = new EventGroup();
                events.addDisposingListener(audio, "canplaythrough", function (_) {
                    _mediaElements.remove(ref);
                    handleLoad(entry, new HtmlSound(audio));
                });
                events.addDisposingListener(audio, "error", function (_) {
                    _mediaElements.remove(ref);
                    var code = audio.error.code;
                    if (code == 3 || code == 4) {
                        // If the song successfully downloaded but this browser can't play it for
                        // some reason (MEDIA_ERR_DECODE or MEDIA_ERR_SRC_NOT_SUPPORTED), warn and
                        // press on with an empty sound.
                        Log.warn("Couldn't decode HTML5 audio, ignoring this asset",
                            ["url", url, "code", code]);
                        handleLoad(entry, DummySound.getInstance());
                    } else {
                        handleError(entry, "Failed to load audio: " + audio.error.code);
                    }
                });
                events.addListener(audio, "progress", function (_) {
                    if (audio.buffered.length > 0 && audio.duration > 0) {
                        // Estimate the bytes downloaded based on the available time range
                        var progress = audio.buffered.end(0) / audio.duration;
                        handleProgress(entry, Std.int(progress*entry.bytes));
                    }
                });

                audio.src = url;
                audio.load();
            }

        case Data:
            downloadText(url, entry, function (text) {
                handleLoad(entry, new BasicFile(text));
            });
        }
    }

    override private function getAssetFormats (fn :Array<AssetFormat> -> Void)
    {
        if (_supportedFormats == null) {
            _supportedFormats = new Promise();
            detectImageFormats(function (imageFormats) {
                _supportedFormats.result = _platform.getRenderer().getCompressedTextureFormats()
                    .concat(imageFormats).concat(detectAudioFormats()).concat([Data]);
            });
        }
        _supportedFormats.get(fn);
    }

    inline private function downloadArrayBuffer (url :String, entry :AssetEntry, onLoad :ArrayBuffer -> Void)
    {
        download(url, entry, "arraybuffer", onLoad);
    }

    inline private function downloadBlob (url :String, entry :AssetEntry, onLoad :Blob -> Void)
    {
        download(url, entry, "blob", onLoad);
    }

    inline private function downloadText (url :String, entry :AssetEntry, onLoad :String -> Void)
    {
        download(url, entry, "text", onLoad);
    }

    private function download (url :String, entry :AssetEntry, responseType :String, onLoad :Dynamic -> Void)
    {
        var xhr = new XMLHttpRequest();

        var lastActivity = 0.0;
        var start = function () {
            lastActivity = HtmlUtil.now();
            xhr.open("GET", url, true);
            xhr.responseType = responseType;
            if (xhr.responseType == "") {
                // Dumb hack for iOS 6, which supports blobs but not the blob responseType
                xhr.responseType = "arraybuffer";
            }
            xhr.send();
        };

        var interval = 0;
        if (untyped __js__("typeof")(xhr.onprogress) != "undefined") {
            var attempts = XHR_ATTEMPTS;
            xhr.onprogress = function (event :Dynamic) {
                lastActivity = HtmlUtil.now();
                handleProgress(entry, event.loaded);
            };
            interval = Browser.window.setInterval(function () {
                // If the download has started, and enough time has passed since the last progress
                // event, consider it stalled and abort
                if (xhr.readyState >= 1 && HtmlUtil.now() - lastActivity > XHR_TIMEOUT) {
                    xhr.abort();

                    // Retry stalled connections a few times
                    --attempts;
                    if (attempts > 0) {
                        Log.warn("Retrying stalled asset request", ["url", entry.url]);
                        start();
                    } else {
                        Browser.window.clearInterval(interval);
                        handleError(entry, "Request timed out");
                    }
                }
            }, 1000);
        }

        xhr.onload = function (_) {
            Browser.window.clearInterval(interval);

            var response :Dynamic = xhr.response;
            if (response == null) {
                // Hack for IE9, which doesn't have xhr.response, only responseText
                response = xhr.responseText;
            } else if (responseType == "blob" && xhr.responseType == "arraybuffer") {
                // Dumb hack for iOS 6, which supports blobs but not the blob responseType
                response = new Blob([xhr.response]);
            }
            onLoad(response);
        };
        xhr.onerror = function (_) {
            Browser.window.clearInterval(interval);
            handleError(entry, "Failed to load asset: error #" + xhr.status);
        };

        start();
        return xhr;
    }

    private static function detectImageFormats (fn :Array<AssetFormat> -> Void)
    {
        var formats = [PNG, JPG, GIF];

        var formatTests = 2;
        var checkRemaining = function () {
            // Called when an image test completes
            --formatTests;
            if (formatTests == 0) {
                fn(formats);
            }
        };

        // Detect WebP-lossless support (and assume that lossy works where lossless does)
        // https://github.com/Modernizr/Modernizr/blob/master/feature-detects/img/webp-lossless.js
        var webp = Browser.document.createImageElement();
        webp.onload = webp.onerror = function (_) {
            if (webp.width == 1) {
                formats.unshift(WEBP);
            }
            checkRemaining();
        };
        webp.src = "data:image/webp;base64,UklGRhoAAABXRUJQVlA4TA0AAAAvAAAAEAcQERGIiP4HAA==";

        // Detect JPEG XR support
        var jxr = Browser.document.createImageElement();
        jxr.onload = jxr.onerror = function (_) {
            if (jxr.width == 1) {
                formats.unshift(JXR);
            }
            checkRemaining();
        };
        // The smallest JXR I could generate (where pixel.tif is a 1x1 black image)
        // ./jpegxr pixel.tif -c -o pixel.jxr -f YOnly -q 255 -b DCONLY -a 0 -w
        jxr.src = "data:image/vnd.ms-photo;base64,SUm8AQgAAAAFAAG8AQAQAAAASgAAAIC8BAABAAAAAQAAAIG8BAABAAAAAQAAAMC8BAABAAAAWgAAAMG8BAABAAAAHwAAAAAAAAAkw91vA07+S7GFPXd2jckNV01QSE9UTwAZAYBxAAAAABP/gAAEb/8AAQAAAQAAAA==";
    }

    private static function detectAudioFormats () :Array<AssetFormat>
    {
        // Detect basic support for HTML5 audio
        var audio = Browser.document.createAudioElement();
        if (audio == null || audio.canPlayType == null) {
            Log.warn("Audio is not supported at all in this browser!");
            return [];
        }

        // Reject browsers that claim to support audio, but are too buggy or incomplete
        var blacklist = ~/\b(iPhone|iPod|iPad|Android)\b/;
        var userAgent = Browser.window.navigator.userAgent;
        if (!WebAudioSound.supported && blacklist.match(userAgent)) {
            Log.warn("HTML5 audio is blacklisted for this browser", ["userAgent", userAgent]);
            return [];
        }

        // Select what formats the browser supports
        var types = [
            { format: M4A,  mimeType: "audio/mp4; codecs=mp4a" },
            { format: MP3,  mimeType: "audio/mpeg" },
            { format: OPUS, mimeType: "audio/ogg; codecs=opus" },
            { format: OGG,  mimeType: "audio/ogg; codecs=vorbis" },
            { format: WAV,  mimeType: "audio/wav" },
        ];
        var result = [];
        for (type in types) {
            // IE9's canPlayType() will throw an error in some rare cases:
            // https://github.com/Modernizr/Modernizr/issues/224
            var canPlayType = "";
            try canPlayType = audio.canPlayType(type.mimeType)
            catch (_ :Dynamic) {}

            if (canPlayType != "") {
                result.push(type.format);
            }
        }
        return result;
    }

    private static function supportsBlob () :Bool
    {
        if (_detectBlobSupport) {
            _detectBlobSupport = false;

            var xhr = new XMLHttpRequest();
            // Hack for IE, which throws an InvalidStateError upon setting the responseType when
            // in the UNSENT state, despite the spec being clear about only throwing in LOADING
            // or DONE: http://www.w3.org/TR/XMLHttpRequest2/#dom-xmlhttprequest-responsetype
            //
            // Forcing it into the OPENED state does the trick, and doesn't actually send the
            // request so it's all good.
            xhr.open("GET", ".", true);

            // Ensure the blob responseType is supported
            xhr.responseType = "blob";
            if (xhr.responseType != "blob") {
                return false;
            }

            _URL = HtmlUtil.loadExtension("URL").value;
        }
        return _URL != null && _URL.createObjectURL != null;
    }

    private static inline var XHR_TIMEOUT = 5000;
    private static inline var XHR_ATTEMPTS = 4;

    private static var _supportedFormats :Promise<Array<AssetFormat>> = null;

    /**
     * Media elements get GCed during loading in Chrome and IE9. The spec is clear that elements
     * shouldn't be GCed while playing, but vague about GCing while loading. So, maintain a hard
     * reference to all media elements being loaded to prevent GC.
     */
    private static var _mediaElements :Map<Int,Dynamic>;
    private static var _mediaRefCount = 0;

    private static var _detectBlobSupport = true;
    private static var _URL :Dynamic = null;
}
