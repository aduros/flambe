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

                    var renderer = HtmlAppDriver.instance.renderer;
                    renderer.uploadTexture(texture);
                    handleLoad(entry, texture);
                };
                image.onerror = function (_) {
                    handleError("Failed to load image " + entry.url);
                };
                image.src = entry.url;

            case Audio:
                // If we made it this far, we definitely support audio and can play this asset
                var audio :Dynamic = Lib.document.createElement("audio");
                audio.preload = "auto"; // Hint that we want to preload the entire file

                var onCanPlayThrough = null;
                onCanPlayThrough = function () {
                    // Firefox fires this event multiple times during loading, so only handle it
                    // the first time...
                    audio.removeEventListener("canplaythrough", onCanPlayThrough, false);

                    handleLoad(entry, new HtmlSound(audio));
                };
                audio.addEventListener("canplaythrough", onCanPlayThrough, false);
                audio.addEventListener("error", function (_) {
                    handleError("Failed to load audio " + entry.url + ", code=" + audio.error.code);
                }, false);
                // TODO(bruno): Handle progress events
                audio.src = entry.url;
                audio.load();

            case Data:
                var http = new Http(entry.url);
                http.onData = function (data) {
                    handleLoad(entry, data);
                };
                http.onError = handleError;
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
        if (blacklist.match(Lib.window.navigator.userAgent)) {
            return [];
        }

        // Select what formats the browser supports and order them by confidence
        var result = [];
        var formats = [
            { extension: "ogg", type: "audio/ogg; codecs=vorbis" },
            { extension: "m4a", type: "audio/mp4; codecs=mp4a" },
            { extension: "mp3", type: "audio/mpeg" },
            { extension: "wav", type: "audio/wav" },
        ];
        for (confidence in [ "probably", "maybe" ]) {
            for (format in formats) {
                if (element.canPlayType(format.type) == confidence) {
                    result.push(format.extension);
                }
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
}
