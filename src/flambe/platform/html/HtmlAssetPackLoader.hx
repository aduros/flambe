//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Dom;
import js.Lib;

import haxe.Http;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
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
        switch (entry.type) {
        case Image:
            var image :Dynamic = untyped __new__("Image");
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
                sendRequest(url, entry, "blob", function (blob) {
                    image.src = _URL.createObjectURL(blob);
                });
            } else {
                image.src = url;
            }

        case Audio:
            // If we made it this far, we definitely support audio and can play this asset
            if (WebAudioSound.supported) {
                sendRequest(url, entry, "arraybuffer", function (buffer) {
                    WebAudioSound.ctx.decodeAudioData(buffer, function (decoded) {
                        handleLoad(entry, new WebAudioSound(decoded));
                    }, function () {
                        // Happens in iOS 6 beta for some sounds that should be able to play. It
                        // seems that monochannel audio will always fail, try converting to stereo.
                        // Since this happens unpredictably, continue with a DummySound rather than
                        // rejecting the entire asset pack.
                        Log.warn("Couldn't decode Web Audio, ignoring this asset." +
                            " Is this a buggy browser?", ["url", url]);
                        handleLoad(entry, DummySound.getInstance());
                    });
                });

            } else {
                var audio :Dynamic = Lib.document.createElement("audio");
                audio.preload = "auto"; // Hint that we want to preload the entire file

                // Maintain a hard reference to the audio during loading to prevent GC on some
                // browsers
                var ref = ++_mediaRefCount;
                if (_mediaElements == null) {
                    _mediaElements = new IntHash();
                }
                _mediaElements.set(ref, audio);

                var events = new EventGroup();
                events.addDisposingListener(audio, "canplaythrough", function (_) {
                    _mediaElements.remove(ref);
                    handleLoad(entry, new HtmlSound(audio));
                });
                events.addDisposingListener(audio, "error", function (_) {
                    _mediaElements.remove(ref);
                    handleError(entry, "Failed to load audio: " + audio.error.code);
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
            sendRequest(url, entry, "text", function (text) {
                handleLoad(entry, text);
            });
        }
    }

    override private function getAudioFormats () :Array<String>
    {
        if (_audioFormats == null) {
            _audioFormats = detectAudioFormats();
        }
        return _audioFormats;
    }

    private function sendRequest (url :String, entry :AssetEntry, responseType :String, onLoad :Dynamic -> Void)
    {
        var xhr :Dynamic = untyped __new__("XMLHttpRequest");

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
            interval = (untyped Lib.window).setInterval(function () {
                // If the download has started, and enough time has passed since the last progress
                // event, consider it stalled and abort
                if (xhr.readyState >= 1 && HtmlUtil.now() - lastActivity > XHR_TIMEOUT) {
                    xhr.abort();

                    // Retry stalled connections a few times
                    --attempts;
                    if (attempts > 0) {
                        start();
                    } else {
                        (untyped Lib.window).clearInterval(interval);
                        handleError(entry, "Failed to load asset: timeout");
                    }
                }
            }, 1000);
        }

        xhr.onload = function (_) {
            (untyped Lib.window).clearInterval(interval);

            var response = xhr.response;
            if (responseType == "blob" && xhr.responseType == "arraybuffer") {
                // Dumb hack for iOS 6, which supports blobs but not the blob responseType
                response = untyped __new__("Blob", [xhr.response]);
            }
            onLoad(response);
        };
        xhr.onerror = function (_) {
            (untyped Lib.window).clearInterval(interval);
            handleError(entry, "Failed to load asset: error #" + xhr.status);
        };

        start();
        return xhr;
    }

    private static function detectAudioFormats () :Array<String>
    {
        // Detect basic support for HTML5 audio
        var element :Dynamic = Lib.document.createElement("audio");
        if (element == null || element.canPlayType == null) {
            return [];
        }

        // Reject browsers that claim to support audio, but are too buggy or incomplete
        var blacklist = ~/\b(iPhone|iPod|iPad|Android)\b/;
        if (!WebAudioSound.supported && blacklist.match(Lib.window.navigator.userAgent)) {
            return [];
        }

        // Select what formats the browser supports
        var formats = [
            { extension: "m4a", type: "audio/mp4; codecs=mp4a" },
            { extension: "mp3", type: "audio/mpeg" },
            { extension: "ogg", type: "audio/ogg; codecs=vorbis" },
            { extension: "wav", type: "audio/wav" },
        ];
        var result = [];
        for (format in formats) {
            // IE9's canPlayType() will throw an error in some rare cases:
            // https://github.com/Modernizr/Modernizr/issues/224
            var canPlayType = "";
            try canPlayType = element.canPlayType(format.type)
            catch (_ :Dynamic) {}

            if (canPlayType != "") {
                result.push(format.extension);
            }
        }
        return result;
    }

    private static function supportsBlob () :Bool
    {
        if (_detectBlobSupport) {
            _detectBlobSupport = false;
            try {
                var xhr = untyped __new__("XMLHttpRequest");
                xhr.responseType = "blob";
            } catch (_ :Dynamic) {
                return false;
            }
            _URL = HtmlUtil.loadExtension("URL").value;
        }
        return _URL != null && _URL.createObjectURL != null;
    }

    private static inline var XHR_TIMEOUT = 5000;
    private static inline var XHR_ATTEMPTS = 4;

    private static var _audioFormats :Array<String>;

    /**
     * Media elements get GCed during loading in Chrome and IE9. The spec is clear that elements
     * shouldn't be GCed while playing, but vague about GCing while loading. So, maintain a hard
     * reference to all media elements being loaded to prevent GC.
     */
    private static var _mediaElements :IntHash<Dynamic>;
    private static var _mediaRefCount = 0;

    private static var _detectBlobSupport = true;
    private static var _URL :Dynamic = null;
}
