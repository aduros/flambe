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
                // TODO(bruno): Uncomment this if content hashing is ever added
                // image.validate = "never";
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
                    handleLoad(entry, texture);
                };
                image.onerror = function (_) {
                    handleError("Failed to load image " + entry.url);
                };
                image.src = entry.url;

            case Data:
                var http = new Http(entry.url);
                http.onData = function (data) {
                    handleLoad(entry, data);
                };
                http.onError = handleError;
                http.request(false);
        }
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
        // On iOS < 5, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/5
        var pattern = ~/(iPhone|iPod|iPad).*OS (\d+)/;
        if (pattern.match(Lib.window.navigator.userAgent)) {
            var version = Std.parseInt(pattern.matched(2));
            return (version < 5);
        }
        return false;
    })();
}
