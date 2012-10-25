//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Keyboard;
import flambe.input.Mouse;
import flambe.input.Pointer;
import flambe.input.Touch;
import flambe.platform.Platform;
import flambe.platform.BasicKeyboard;
import flambe.platform.BasicPointer;
import flambe.platform.MainLoop;
import flambe.storage.Storage;
import flambe.System;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.web.Web;

class HtmlPlatform
    implements Platform
{
    public static var instance (default, null) :HtmlPlatform = new HtmlPlatform();

    public var mainLoop (default, null) :MainLoop;
    public var renderer :Renderer;

    private function new ()
    {
    }

    public function init ()
    {
        Log.info("Initializing HTML platform");

        var canvas :Dynamic = null;
        try {
            // Use the canvas assigned to us by the flambe.js embedder
            canvas = (untyped Lib.window).flambe.canvas;
        } catch (error :Dynamic) {
        }
        Assert.that(canvas != null,
            "Could not find a Flambe canvas! Are you embedding with flambe.js?");

        // Allow the canvas to trap keyboard focus
        canvas.setAttribute("tabindex", "0");
        // ...but hide the focus rectangle
        canvas.style.outlineStyle = "none";

        // Browser optimization hints
        canvas.setAttribute("moz-opaque", "true");
        // canvas.style.webkitTransform = "translateZ(0)";
        // canvas.style.backgroundColor = "#000";

        _stage = new HtmlStage(canvas);
        _pointer = new BasicPointer();
        _mouse = new HtmlMouse(_pointer, canvas);
        _keyboard = new BasicKeyboard();

        renderer = new CanvasRenderer(canvas);
        mainLoop = new MainLoop();

        _container = canvas.parentNode;
        _container.style.overflow = "hidden";
        _container.style.position = "relative";

        var lastTouchTime = 0;
        var onMouse = function (event) {
            if (event.timeStamp - lastTouchTime < 1000) {
                // Ignore if there was too recent a touch event, to filter out mouse events emulated
                // by mobile browsers: http://www.w3.org/TR/touch-events/#mouse-events
                return;
            }
            var bounds = canvas.getBoundingClientRect();
            var x = getX(event, bounds);
            var y = getY(event, bounds);

            switch (event.type) {
            case "mousedown":
                if (event.target == canvas) {
                    event.preventDefault();
                    _mouse.submitDown(x, y, event.button);
                    event.target.focus();
                }

            case "mousemove":
                _mouse.submitMove(x, y);

            case "mouseup":
                _mouse.submitUp(x, y, event.button);

            case "mousewheel", "DOMMouseScroll":
                var velocity = (event.type == "mousewheel") ? event.wheelDelta/40 : -event.detail;
                if (_mouse.submitScroll(x, y, velocity)) {
                    // Only prevent page scrolling if the event was handled
                    event.preventDefault();
                }
            }
        };
        // Add listeners on the window object so dragging and releasing outside of the canvas works
        (untyped window).addEventListener("mousedown", onMouse, false);
        (untyped window).addEventListener("mousemove", onMouse, false);
        (untyped window).addEventListener("mouseup", onMouse, false);

        // But the wheel listener should only go on the canvas
        canvas.addEventListener("mousewheel", onMouse, false);
        canvas.addEventListener("DOMMouseScroll", onMouse, false); // https://bugzil.la/719320

        // Detect touch support. See http://modernizr.github.com/Modernizr/touch.html for more
        // sophisticated detection methods, but this seems to cover all important browsers
        if (untyped __js__("'ontouchstart' in window")) {
            var basicTouch = new BasicTouch(_pointer);
            _touch = basicTouch;

            var onTouch = function (event) {
                var changedTouches :Array<Dynamic> = event.changedTouches;
                var bounds = event.target.getBoundingClientRect();
                lastTouchTime = event.timeStamp;

                switch (event.type) {
                case "touchstart":
                    event.preventDefault();
                    if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) {
                        HtmlUtil.hideMobileBrowser();
                    }
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        basicTouch.submitDown(Std.int(touch.identifier), x, y);
                    }

                case "touchmove":
                    event.preventDefault();
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        basicTouch.submitMove(Std.int(touch.identifier), x, y);
                    }

                case "touchend", "touchcancel":
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        basicTouch.submitUp(Std.int(touch.identifier), x, y);
                    }
                }
            };
            canvas.addEventListener("touchstart", onTouch, false);
            canvas.addEventListener("touchmove", onTouch, false);
            canvas.addEventListener("touchend", onTouch, false);
            canvas.addEventListener("touchcancel", onTouch, false);

        } else {
            _touch = new DummyTouch();
        }

        var onKey = function (event) {
            switch (event.type) {
            case "keydown":
                event.preventDefault();
                _keyboard.submitDown(event.keyCode);
            case "keyup":
                _keyboard.submitUp(event.keyCode);
            }
        };
        canvas.addEventListener("keydown", onKey, false);
        canvas.addEventListener("keyup", onKey, false);

        // Handle uncaught errors
        var oldErrorHandler = (untyped Lib.window).onerror;
        (untyped Lib.window).onerror = function (message, url, line) {
            System.uncaughtError.emit(message);
            return (oldErrorHandler != null) ? oldErrorHandler(message, url, line) : false;
        };

        // Handle visibility changes if the browser supports them
        // http://www.w3.org/TR/page-visibility/
        var hiddenApi = HtmlUtil.loadExtension("hidden", Lib.document);
        if (hiddenApi.value != null) {
            var onVisibilityChanged = function () {
                System.hidden._ = Reflect.field(Lib.document, hiddenApi.field);
            };
            onVisibilityChanged(); // Update now
            (untyped Lib.document).addEventListener(hiddenApi.prefix + "visibilitychange",
                onVisibilityChanged, false);
            System.hidden.changed.connect(function (hidden,_) {
                if (!hidden) {
                    _skipFrame = true;
                }
            });
        }

        _lastUpdate = Date.now().getTime();
        _skipFrame = false;

        // Use requestAnimationFrame if available, otherwise a fixed FPS setInterval
        // https://developer.mozilla.org/en/DOM/window.mozRequestAnimationFrame
        var requestAnimationFrame = HtmlUtil.loadExtension("requestAnimationFrame").value;
        if (requestAnimationFrame != null) {
            // Use the high resolution, monotonic timer if available
            // http://www.w3.org/TR/hr-time/
            var performance :{ now :Void -> Float } = untyped Lib.window.performance;
            var hasPerfNow = (performance != null) && HtmlUtil.polyfill("now", performance);

            if (hasPerfNow) {
                // performance.now is relative to navigationStart, rather than a timestamp
                _lastUpdate = performance.now();
            } else {
                Log.warn("No monotonic timer support, falling back to the system date");
            }

            // Do we need to minimize the mainloop calls with requestAnimationFrame?
            _checkDT = (System.FPS<60) ? true : false;
            var updateFrame = null;
            updateFrame = function (now :Float) {
                update(hasPerfNow ? performance.now() : now);
                requestAnimationFrame(updateFrame, canvas);
            };
            requestAnimationFrame(updateFrame, canvas);

        } else {
            Log.warn("No requestAnimationFrame support, falling back to setInterval");
            (untyped Lib.window).setInterval(function () {
                update(Date.now().getTime());
            }, 1000/System.FPS);
        }
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
                // Browsers may throw an error on accessing localStorage:
                // http://dev.w3.org/html5/webstorage/#dom-localstorage
            }
            if (localStorage != null) {
                _storage = new HtmlStorage(localStorage);
            } else {
                Log.warn("localStorage is unavailable, falling back to unpersisted storage");
                _storage = new DummyStorage();
            }
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
            Log.warn("Error calling native method", ["error", e]);
            return null;
        }
    }

    public function createLogHandler (tag :String) :LogHandler
    {
#if (debug || flambe_keep_logs)
        if (HtmlLogHandler.isSupported()) {
            return new HtmlLogHandler(tag);
        }
#end
        return null;
    }

    private function update (now :Float)
    {
        var dt = (now - _lastUpdate)/1000;
	
	// Minimize update calls using delta time?
	if (_checkDT && dt < System.FPS / 1000)
        {
	    return;
        }
	
        _lastUpdate = now;

        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        mainLoop.render(renderer);
    }

    public function getPointer () :Pointer
    {
        return _pointer;
    }

    public function getMouse () :Mouse
    {
        return _mouse;
    }

    public function getTouch () :Touch
    {
        return _touch;
    }

    public function getKeyboard () :Keyboard
    {
        return _keyboard;
    }

    public function getWeb () :Web
    {
        if (_web == null) {
            _web = new HtmlWeb(_container);
        }
        return _web;
    }

    private function getX (event :Dynamic, bounds :Dynamic) :Float
    {
        return _stage.scaleFactor*(event.clientX - bounds.left);
    }

    private function getY (event :Dynamic, bounds :Dynamic) :Float
    {
        return _stage.scaleFactor*(event.clientY - bounds.top);
    }

    private var _stage :HtmlStage;
    private var _pointer :BasicPointer;
    private var _mouse :HtmlMouse;
    private var _touch :Touch;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;
    private var _web :Web;

    private var _container :Dynamic;

    private var _lastUpdate :Float;
    private var _skipFrame :Bool;
    private var _checkDT :Bool;
}
