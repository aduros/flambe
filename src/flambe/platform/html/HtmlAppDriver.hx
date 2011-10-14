//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.KeyEvent;
import flambe.display.MouseEvent;
import flambe.display.Texture;
import flambe.Entity;
import flambe.Input;
import flambe.platform.AppDriver;
import flambe.platform.MainLoop;
import flambe.System;
import flambe.util.Promise;
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

        _stage = new HtmlStage(_canvas);

        _loop = new MainLoop(new HtmlDrawingContext(_canvas));
        _lastUpdate = Date.now().getTime();

        // Use requestAnimationFrame if available, otherwise a 60 FPS setInterval
        // https://developer.mozilla.org/en/DOM/window.mozRequestAnimationFrame
        var requestAnimationFrame = loadExtension("requestAnimationFrame");
        if (requestAnimationFrame != null) {
            var updateFrame = null;
            updateFrame = function (now) {
                update(now);
                requestAnimationFrame(updateFrame, _canvas);
            };
            requestAnimationFrame(updateFrame, _canvas);
        } else {
            (untyped Lib.window.setInterval)(function () {
                update(Date.now().getTime());
            }, 1000/60);
        }

        // Allow the canvas to be focusable
        _canvas.setAttribute("tabindex", "0");
        // ...but hide the focus rectangle
        _canvas.style.outlineStyle = "none";

        _canvas.addEventListener("mousedown", function (event) {
            Input.mouseDown.emit(createMouseEvent(event));
            _canvas.focus();
        }, false);
        _canvas.addEventListener("mousemove", function (event) {
            Input.mouseMove.emit(createMouseEvent(event));
        }, false);
        _canvas.addEventListener("mouseup", function (event) {
            Input.mouseUp.emit(createMouseEvent(event));
        }, false);
        _canvas.addEventListener("keydown", function (event) {
            event.preventDefault();
            if (!Input.isKeyDown(event.keyCode)) {
                Input.keyDown.emit(new KeyEvent(event.keyCode));
            }
        }, false);
        _canvas.addEventListener("keyup", function (event) {
            event.preventDefault();
            if (Input.isKeyDown(event.keyCode)) {
                Input.keyUp.emit(new KeyEvent(event.keyCode));
            }
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

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new HtmlAssetPackLoader(manifest).promise;
    }

    public function getStage () :Stage
    {
        return _stage;
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

    public function callNative (funcName :String, params :Array<Dynamic>) :Dynamic
    {
        if (params == null) {
            params = [];
        }
        var func = Reflect.field(Lib.window, funcName);
        try {
            return Reflect.callMethod(null, func, params);
        } catch (e :Dynamic) {
            return null;
        }
    }

    private function update (now :Float)
    {
        var dt = now - _lastUpdate;
        _lastUpdate = now;

        _loop.update(cast dt);
        _loop.render();
    }

    private static function createMouseEvent (domEvent :Dynamic) :MouseEvent
    {
        var rect = domEvent.target.getBoundingClientRect();
        return new MouseEvent(
            domEvent.clientX - rect.left,
            domEvent.clientY - rect.top);
    }

    // Load a prefixed vendor extension
    private static function loadExtension (name :String, ?obj :Dynamic) :Dynamic
    {
        if (obj == null) {
            obj = Lib.window;
        }

        // Try to load it as is
        var extension = Reflect.field(obj, name);
        if (extension != null) {
            return extension;
        }

        // Look through common vendor prefixes
        var capitalized = name.substr(0, 1).toUpperCase() + name.substr(1);
        for (prefix in [ "webkit", "moz", "ms", "o", "khtml" ]) {
            var extension = Reflect.field(obj, prefix + capitalized);
            if (extension != null) {
                return extension;
            }
        }

        // Not found
        return null;
    }

    private var _loop :MainLoop;
    private var _lastUpdate :Float;

    private var _canvas :Dynamic;
    private var _stage :Stage;
    private var _storage :Storage;
}
