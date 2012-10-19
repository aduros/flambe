//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Dom;
import js.Lib;
import js.XMLHttpRequest;

import haxe.Http;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.util.Signal0;
import flambe.util.Signal1;

class HtmlAssetPackLoader extends BasicAssetPackLoader
{
    public function new (manifest :Manifest)
    {
        super(manifest);
    }

    override private function loadEntry (entry :AssetEntry)
    {
        switch (entry.type) {
        case Image:
            var image :Image = untyped __js__ ("new Image()");
            image.onload = function (_) {
                image.onload = null;
                image.onerror = null;

                var texture = new HtmlTexture();
                if (CANVAS_TEXTURES) {
                    var canvas :Dynamic = Lib.document.createElement("canvas");
                    canvas.width = image.width;
                    canvas.height = image.height;
                    canvas.getContext("2d").drawImage(image, 0, 0);
                    image = null; // Free it up
                    texture.image = canvas;
                } else {
                    texture.image = image;
                }

                var renderer = HtmlPlatform.instance.renderer;
                renderer.uploadTexture(texture);
                handleLoad(entry, texture);
            };
            image.onerror = function (_) {
                handleError("Failed to load image: " + entry.url);
            };

            image.src = entry.url;

        case Audio:
            // If we made it this far, we definitely support audio and can play this asset
            if (WebAudioSound.supported) {
                var req = untyped __new__(XMLHttpRequest);
                req.open("GET", entry.url, true);
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
                            " Is this a buggy browser?", ["url", entry.url]);
                        handleLoad(entry, DummySound.getInstance());
                    });
                };
                req.onerror = function () {
                    handleError("Failed to load audio " + entry.url);
                };
                // TODO(bruno): Handle progress events
                req.send();

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
                    handleError("Failed to load audio " + entry.url + ", code=" + audio.error.code);
                });


                // TODO(bruno): Handle progress events
                audio.src = entry.url;
                audio.load();
            }

        case Data:
            var http = new Http(entry.url);
            http.onData = function (data) {
                handleLoad(entry, data);
            };
            http.onError = function (error) {
                handleError("Failed to load data " + entry.url + ", error=" + error);
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
        var element :Dynamic = Lib.document.createElement("audio");
        if (element == null || element.canPlayType == null) {
            return [];
        }

        // Reject browsers that claim to support audio, but are too buggy or incomplete
        var blacklist = ~/\b(iPhone|iPod|iPad|Android)\b/;
        if (!WebAudioSound.supported && blacklist.match(Lib.window.navigator.userAgent)) {
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

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool = (function () {
        // On iOS, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/8
        var pattern = ~/(iPhone|iPod|iPad)/;
        return pattern.match(Lib.window.navigator.userAgent);
    })();

    private static var _audioFormats :Array<String>;

    /**
     * Media elements get GCed during loading in Chrome and IE9. The spec is clear that elements
     * shouldn't be GCed while playing, but vague about about GCing while loading. So, maintain a
     * hard reference to all media elements being loaded to prevent GC.
     */
    private static var _mediaElements :IntHash<Dynamic>;
    private static var _mediaRefCount = 0;
}
