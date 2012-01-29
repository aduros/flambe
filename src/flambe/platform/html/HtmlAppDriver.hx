//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Keyboard;
import flambe.input.KeyEvent;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
import flambe.platform.AppDriver;
import flambe.platform.BasicKeyboard;
import flambe.platform.BasicPointer;
import flambe.platform.MainLoop;
import flambe.System;
import flambe.util.Promise;
import flambe.util.Signal1;

class HtmlAppDriver
    implements AppDriver
{
    public var stage (getStage, null) :Stage;
    public var storage (getStorage, null) :Storage;
    public var pointer (getPointer, null) :Pointer;
    public var keyboard (getKeyboard, null) :Keyboard;
    public var locale (getLocale, null) :String;

    public var mainLoop (default, null) :MainLoop;

    public static function getInstance () :HtmlAppDriver
    {
        if (_instance == null) {
            _instance = new HtmlAppDriver();
        }
        return _instance;
    }

    private function new ()
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
        _pointer = new BasicPointer();
        _keyboard = new BasicKeyboard();

        mainLoop = new MainLoop(new HtmlDrawingContext(_canvas));
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
            (untyped Lib.window).setInterval(function () {
                update(Date.now().getTime());
            }, 1000/60);
        }

        // Allow the canvas to trap keyboard focus
        _canvas.setAttribute("tabindex", "0");
        // ...but hide the focus rectangle
        _canvas.style.outlineStyle = "none";

        // Browser optimization hints
        _canvas.setAttribute("moz-opaque", "true");
        // canvas.style.webkitTransform = "translateZ(0)";
        // canvas.style.backgroundColor = "#000";

        _canvas.addEventListener("mousedown", function (event) {
            event.preventDefault();
            _pointer.submitDown(createPointerEvent(event));
            _canvas.focus();
        }, false);
        _canvas.addEventListener("mousemove", function (event) {
            _pointer.submitMove(createPointerEvent(event));
        }, false);
        _canvas.addEventListener("mouseup", function (event) {
            _pointer.submitUp(createPointerEvent(event));
        }, false);
        _canvas.addEventListener("keydown", function (event) {
            event.preventDefault();
            _keyboard.submitDown(new KeyEvent(event.keyCode));
        }, false);
        _canvas.addEventListener("keyup", function (event) {
            _keyboard.submitUp(new KeyEvent(event.keyCode));
        }, false);

        var touchId = -1;
        var getPointerTouch = function (domEvent) :Bool {
            var changedTouches :Array<Dynamic> = domEvent.changedTouches;
            for (touch in changedTouches) {
                if (touch.identifier == touchId) {
                    return touch;
                }
            }
            return null;
        };
        var onTouchEnd = function (domEvent) {
            var touch = getPointerTouch(domEvent);
            if (touch != null) {
                _pointer.submitUp(createPointerEvent(touch));
                touchId = -1;
            }
        };
        _canvas.addEventListener("touchstart", function (domEvent) {
            domEvent.preventDefault();
            if (touchId >= 0) {
                // We're already handling a finger
                return;
            }
            hideMobileBrowser();

            var touch = domEvent.changedTouches[0];
            touchId = touch.identifier;
            _pointer.submitDown(createPointerEvent(touch));
        }, false);
        _canvas.addEventListener("touchmove", function (domEvent) {
            // preventDefault necessary here too?
            var touch = getPointerTouch(domEvent);
            if (touch != null) {
                _pointer.submitMove(createPointerEvent(touch));
            }
        }, false);
        _canvas.addEventListener("touchend", onTouchEnd, false);
        _canvas.addEventListener("touchcancel", onTouchEnd, false);

        // Handle uncaught errors
        var oldErrorHandler = (untyped Lib.window).onerror;
        (untyped Lib.window).onerror = function (message, url, line) {
            System.uncaughtError.emit(message);
            return (oldErrorHandler != null) ? oldErrorHandler(message, url, line) : false;
        };

        (untyped Lib.window).addEventListener("orientationchange", function (event) {
            hideMobileBrowser();
        }, false);
        hideMobileBrowser();
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

        mainLoop.update(cast dt);
        mainLoop.render();
    }

    public function getPointer () :Pointer
    {
        return _pointer;
    }

    public function getKeyboard () :Keyboard
    {
        return _keyboard;
    }

    private static function createPointerEvent (domEvent :Dynamic) :PointerEvent
    {
        var rect = domEvent.target.getBoundingClientRect();
        return new PointerEvent(
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

    private static function hideMobileBrowser ()
    {
        Lib.window.scrollTo(1, 0);
    }

    private static var _instance :HtmlAppDriver;

    private var _lastUpdate :Float;

    private var _canvas :Dynamic;
    private var _stage :Stage;
    private var _pointer :BasicPointer;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;
}
