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
import flambe.util.Signal1;

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

        try {
            // Use the canvas assigned to us by the flambe.js embedder
            _canvas = (untyped Lib.window).flambe.canvas;
        } catch (error :Dynamic) {
        }
        if (_canvas == null) {
            // We weren't loaded with the embedder... try to locate a #flambe-canvas
            _canvas = Lib.document.getElementById("flambe-canvas");
        }
        if (_canvas == null) {
            throw "Could not find a Flambe canvas! Are you not embedding with flambe.js?";
        }

        var loop = new MainLoop(new HtmlDrawingContext(_canvas));
        var lastUpdate = Date.now().getTime();
        untyped Lib.window.setInterval(function () {
            var now = Date.now().getTime();
            var dt = now - lastUpdate;
            lastUpdate = now;

            loop.update(cast dt);
            loop.render();
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

        var touchId = -1;
        var maybeEmit = function (signal :Signal1<MouseEvent>, event) :Bool {
            var changedTouches :Array<Dynamic> = event.changedTouches;
            for (touch in changedTouches) {
                if (touch.identifier == touchId) {
                    signal.emit(createMouseEvent(touch));
                    return true;
                }
            }
            return false;
        };
        var onTouchEnd = function (event) {
            if (maybeEmit(Input.mouseUp, event)) {
                touchId = -1;
            }
        };
        _canvas.addEventListener("touchstart", function (event) {
            event.preventDefault();
            if (touchId >= 0) {
                // We're already handling a finger
                return;
            }
            Lib.window.scrollTo(0, 0);

            var touch = event.changedTouches[0];
            touchId = touch.identifier;
            Input.mouseDown.emit(createMouseEvent(touch));
        }, false);
        _canvas.addEventListener("touchmove", function (event) {
            maybeEmit(Input.mouseMove, event);
            // preventDefault necessary here too?
        }, false);
        _canvas.addEventListener("touchend", onTouchEnd, false);
        _canvas.addEventListener("touchcancel", onTouchEnd, false);

        // Hide the status bar on Mobile Safari
        Lib.window.scrollTo(0, 0);
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
            var localStorage = null;
            try {
                localStorage = (untyped Lib.window).localStorage;
            } catch (error :Dynamic) {
                // Browser may throw a exception on accessing localStorage:
                // http://dev.w3.org/html5/webstorage/#dom-localstorage
            }
            // TODO: Why is a cast necessary here? Compiler bug? Try without it in a release version
            _storage = (localStorage != null) ?
                new HtmlStorage(localStorage) : cast new DummyStorage();
        }
        return _storage;
    }

    public function getLocale () :String
    {
        return untyped Lib.window.navigator.language;
    }

    private var _canvas :Dynamic;
    private var _storage :Storage;
}
