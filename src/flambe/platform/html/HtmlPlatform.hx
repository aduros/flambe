//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.animation.AnimatedFloat;
import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.display.Texture;
import flambe.external.External;
import flambe.input.Keyboard;
import flambe.input.Mouse;
import flambe.input.Pointer;
import flambe.input.Touch;
import flambe.platform.BasicKeyboard;
import flambe.platform.BasicPointer;
import flambe.platform.MainLoop;
import flambe.platform.Platform;
import flambe.storage.Storage;
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

        _renderer = createRenderer(canvas);
        System.hasGPU._ = true;

        mainLoop = new MainLoop();

        _container = canvas.parentNode;
        _container.style.overflow = "hidden";
        _container.style.position = "relative";

        // Prevent double tap zooming on IE10. Maybe this should be in the MSPointer block below,
        // but I have no idea without testing, so apply it always
        // http://msdn.microsoft.com/en-us/library/windows/apps/Hh767313.aspx
        _container.style.msTouchAction = "none";

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
        var standardTouch :Bool = untyped __js__("typeof")(Lib.window.ontouchstart) != "undefined";

        // The pointer event handles mouse movement, touch events, and stylus events.
        // We check to see if multiple points are supported indicating true touch support.
        // http://blogs.msdn.com/b/ie/archive/2011/10/19/handling-multi-touch-and-mouse-input-in-all-browsers.aspx
        var msTouch :Bool = untyped __js__("'msMaxTouchPoints' in window.navigator && (window.navigator.msMaxTouchPoints > 1)");

        if (standardTouch || msTouch) {
            var basicTouch = new BasicTouch(_pointer, msTouch ?
                untyped __js__("window.navigator.msMaxTouchPoints") : 4);
            _touch = basicTouch;

            var onTouch = function (event :Dynamic) {
                var changedTouches :Array<Dynamic> = standardTouch ?  event.changedTouches : [ event ];
                var bounds = event.target.getBoundingClientRect();
                lastTouchTime = event.timeStamp;

                switch (event.type) {
                case "touchstart", "MSPointerDown":
                    event.preventDefault();
                    if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) {
                        HtmlUtil.hideMobileBrowser();
                    }
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        var id = Std.int(standardTouch ? touch.identifier : touch.pointerId);
                        basicTouch.submitDown(id, x, y);
                    }

                case "touchmove", "MSPointerMove":
                    event.preventDefault();
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        var id = Std.int(standardTouch ? touch.identifier : touch.pointerId);
                        basicTouch.submitMove(id, x, y);
                    }

                case "touchend", "touchcancel", "MSPointerUp":
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        var id = Std.int(standardTouch ? touch.identifier : touch.pointerId);
                        basicTouch.submitUp(id, x, y);
                    }
                }
            };

            if (standardTouch) {
                canvas.addEventListener("touchstart", onTouch, false);
                canvas.addEventListener("touchmove", onTouch, false);
                canvas.addEventListener("touchend", onTouch, false);
                canvas.addEventListener("touchcancel", onTouch, false);
            } else {
                canvas.addEventListener("MSPointerDown", onTouch, false);
                canvas.addEventListener("MSPointerMove", onTouch, false);
                canvas.addEventListener("MSPointerUp", onTouch, false);
            }

        } else {
            _touch = new DummyTouch();
        }

        var onKey = function (event) {
            switch (event.type) {
            case "keydown":
                if (_keyboard.submitDown(event.keyCode)) {
                    event.preventDefault();
                }
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
        } else {

            // Adds some lock screen support for iOS, possibly other devices that don't support the page visibility api.
            var onPageTransitionChange = function(event) {
                var hide:Bool = (Reflect.getProperty(event,"type") != 'pageshow');
                if(System.hidden._ != hide) {
                    System.hidden._ = hide;
                }
            };
            System.hidden._ = false;
            (untyped Lib.window).addEventListener('pageshow', onPageTransitionChange, false);
            (untyped Lib.window).addEventListener('pagehide', onPageTransitionChange, false);
            
            System.hidden.changed.connect(function (hidden,_) {
                if (!hidden) {
                    _skipFrame = true;
                }
            });

        }

        _lastUpdate = HtmlUtil.now();
        _skipFrame = false;

        // Use requestAnimationFrame if available, otherwise a 60 FPS setInterval
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

            var updateFrame = null;
            updateFrame = function (now :Float) {
                update(hasPerfNow ? performance.now() : now);
                requestAnimationFrame(updateFrame, canvas);
            };
            requestAnimationFrame(updateFrame, canvas);

        } else {
            Log.warn("No requestAnimationFrame support, falling back to setInterval");
            (untyped Lib.window).setInterval(function () {
                update(HtmlUtil.now());
            }, 1000/60);
        }
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new HtmlAssetPackLoader(this, manifest).promise;
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
        // https://developer.mozilla.org/en-US/docs/DOM/window.navigator.language
        var locale = (untyped Lib.window).navigator.language;
        if (locale == null) {
            // IE uses the non-standard userLanguage (or browserLanguage or systemLanguage, but
            // userLanguage seems to match String's locale-aware methods)
            locale = (untyped Lib.window).navigator.userLanguage;
        }
        return locale;
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

    public function getTime () :Float
    {
        return HtmlUtil.now() / 1000;
    }

    private function update (now :Float)
    {
        var dt = (now-_lastUpdate) / 1000;
        _lastUpdate = now;

        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        mainLoop.render(_renderer);
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

    public function getExternal () :External
    {
        if (_external == null) {
            _external = new HtmlExternal();
        }
        return _external;
    }

    public function getRenderer () :Renderer
    {
        return _renderer;
    }

    private function getX (event :Dynamic, bounds :Dynamic) :Float
    {
        return _stage.scaleFactor*(event.clientX - bounds.left);
    }

    private function getY (event :Dynamic, bounds :Dynamic) :Float
    {
        return _stage.scaleFactor*(event.clientY - bounds.top);
    }

    private function createRenderer (canvas :Dynamic) :Renderer
    {
#if flambe_enable_webgl
        for (name in ["webgl", "experimental-webgl"]) {
            var gl = canvas.getContext(name, {alpha: false, depth: false});
            if (gl != null) {
                return new WebGLRenderer(_stage, gl);
            }
        }
        Log.info("WebGL not available, falling back to canvas");
#end
        return new CanvasRenderer(canvas);
    }

    private var _stage :HtmlStage;
    private var _pointer :BasicPointer;
    private var _mouse :HtmlMouse;
    private var _touch :Touch;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;
    private var _web :Web;
    private var _external :External;
    private var _renderer :Renderer;

    private var _container :Dynamic;

    private var _lastUpdate :Float;
    private var _skipFrame :Bool;
}
