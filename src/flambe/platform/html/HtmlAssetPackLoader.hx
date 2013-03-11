//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;

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
            var image :Image = untyped __new__("Image");
            image.onload = function (_) {
#if debug
                if (image.width > 1024 || image.height > 1024) {
                    Log.warn("Images larger than 1024px on a side will prevent GPU acceleration" +
                        " on some platforms (iOS)", ["url", url,
                        "width", image.width, "height", image.height]);
                }
#end
                var texture = _platform.getRenderer().createTexture(image);
                if (texture != null) {
                    handleLoad(entry, texture);
                } else {
                    handleTextureError(entry);
                }
            };
            image.onerror = function (_) {
                handleError(entry, "Failed to load image");
            };
            image.src = url;

        case Audio:
            // If we made it this far, we definitely support audio and can play this asset
            if (WebAudioSound.supported) {
                var req = untyped __new__("XMLHttpRequest");
                req.open("GET", url, true);
                req.responseType = "arraybuffer";

                req.onload = function () {
                    WebAudioSound.ctx.decodeAudioData(req.response, function (buffer) {
                        handleLoad(entry, new WebAudioSound(buffer));
                    }, function () {
                        // Happens in iOS 6 beta for some sounds that should be able to play. It
                        // seems that monochannel audio will always fail, try converting to stereo.
                        // Since this happens unpredictably, continue with a DummySound rather than
                        // rejecting the entire asset pack.
                        Log.warn("Couldn't decode Web Audio, ignoring this asset." +
                            " Is this a buggy browser?", ["url", url]);
                        handleLoad(entry, DummySound.getInstance());
                    });
                };
                req.onerror = function () {
                    handleError(entry, "Failed to load audio");
                };
                // TODO(bruno): Handle progress events
                req.send();

            } else {
                var audio :Dynamic = Browser.document.createElement("audio");
                audio.preload = "auto"; // Hint that we want to preload the entire file

                // Maintain a hard reference to the audio during loading to prevent GC on some
                // browsers
                var ref = ++_mediaRefCount;
                if (_mediaElements == null) {
                    _mediaElements = new Map();
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


                // TODO(bruno): Handle progress events
                audio.src = url;
                audio.load();
            }

        case Data:
            var http = new Http(url);
            http.onData = function (data) {
                handleLoad(entry, data);
            };
            http.onError = function (error) {
                handleError(entry, "Failed to load data: " + error);
            };
            http.request(false);
        }
    }

    override private function getAudioFormats () :Array<String>
    {
        if (_audioFormats == null) {
            _audioFormats = detectAudioFormats();
        }
        return _audioFormats;
    }

    private static function detectAudioFormats () :Array<String>
    {
        // Detect basic support for HTML5 audio
        var element :Dynamic = Browser.document.createElement("audio");
        if (element == null || element.canPlayType == null) {
            return [];
        }

        // Reject browsers that claim to support audio, but are too buggy or incomplete
        var blacklist = ~/\b(iPhone|iPod|iPad|Android)\b/;
        if (!WebAudioSound.supported && blacklist.match(Browser.window.navigator.userAgent)) {
            return [];
        }

        // Select what formats the browser supports and order them by confidence
        var formats = [
            { extension: "m4a", type: "audio/mp4; codecs=mp4a" },
            { extension: "mp3", type: "audio/mpeg" },
            { extension: "ogg", type: "audio/ogg; codecs=vorbis" },
            { extension: "wav", type: "audio/wav" },
        ];
        var result = [];
        for (format in formats) {
            if (element.canPlayType(format.type) != "") {
                result.push(format.extension);
            }
        }
        return result;
    }

    override private function handleLoad (entry :AssetEntry, asset :Dynamic)
    {
        // We don't get progress events in JS, the best we can do is to update it when an asset
        // finishes loading
        handleProgress(entry, entry.bytes);
        super.handleLoad(entry, asset);
    }

    private static var _audioFormats :Array<String>;

    /**
     * Media elements get GCed during loading in Chrome and IE9. The spec is clear that elements
     * shouldn't be GCed while playing, but vague about about GCing while loading. So, maintain a
     * hard reference to all media elements being loaded to prevent GC.
     */
    private static var _mediaElements :Map<Int,Dynamic>;
    private static var _mediaRefCount = 0;
}
