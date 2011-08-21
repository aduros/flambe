//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.asset.AssetPackLoader;
import flambe.display.MouseEvent;
import flambe.display.Texture;
import flambe.Entity;
import flambe.Input;
import flambe.platform.AppDriver;
import flambe.platform.MainLoop;
import flambe.System;

class HtmlAppDriver
    implements AppDriver
{
    public function new ()
    {
    }

    public function init (root :Entity)
    {
#if debug
        haxe.Firebug.redirectTraces();
#end

        // The canvas provided by the flambe.js embedder
        _canvas = untyped Lib.window.flambe.canvas;
        if (_canvas == null) {
            // The app is being embedded directly
            _canvas = Lib.document.createElement("canvas");
        }

        var loop = new MainLoop(new HtmlDrawingContext(_canvas));
        var lastUpdate = Date.now().getTime();
        untyped Lib.window.setInterval(function () {
            var now = Date.now().getTime();
            var dt = now - lastUpdate;
            lastUpdate = now;

            loop.runFrame(cast dt);
        }, 1000/60);

        var createMouseEvent = function (data :Dynamic) {
            var event = new MouseEvent();
            var rect = data.target.getBoundingClientRect();
            event.viewX = data.clientX - rect.left;
            event.viewY = data.clientY - rect.top;
            return event;
        };
        _canvas.addEventListener("mousedown", function (event) {
            Input.mouseDown.emit(createMouseEvent(event));
        }, false);
        _canvas.addEventListener("mousemove", function (event) {
            Input.mouseMove.emit(createMouseEvent(event));
        }, false);
        _canvas.addEventListener("mouseup", function (event) {
            Input.mouseUp.emit(createMouseEvent(event));
        }, false);
    }

    public function loadAssetPack (url :String) :AssetPackLoader
    {
        return new HtmlAssetPackLoader(url);
    }

    public function getStageWidth () :Int
    {
        return _canvas.width;
    }

    public function getStageHeight () :Int
    {
        return _canvas.height;
    }

    public function getStorage () :Storage
    {
        if (_storage == null) {
            // TODO: HtmlStorage
            _storage = new DummyStorage();
        }
        return _storage;
    }

    private var _canvas :Dynamic;
    private var _storage :Storage;
}
