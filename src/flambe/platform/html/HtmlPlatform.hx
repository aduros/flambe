//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.subsystem.*;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;

class HtmlPlatform
    implements Platform
{
    public static var instance (default, null) :HtmlPlatform = new HtmlPlatform();

    public var mainLoop (default, null) :MainLoop;
    public var musicPlaying :Bool;

    private function new ()
    {
    }

    public function init ()
    {
        HtmlUtil.fixAndroidMath();

#if html
        // If running in a plain web browser, look up the canvas from the embedder
        var canvas :CanvasElement = null;
        try {
            // Use the canvas assigned to us by the flambe.js embedder
            canvas = (untyped Browser.window).flambe.canvas;
        } catch (error :Dynamic) {
        }
        Assert.that(canvas != null,
            "Could not find a Flambe canvas! Are you embedding with flambe.js?");
#else
        // Otherwise create our own
        var canvas = Browser.document.createCanvasElement();
        Browser.document.getElementById("content").appendChild(canvas);
#end

        // Allow the canvas to trap keyboard focus
        canvas.setAttribute("tabindex", "0");
        // ...but hide the focus rectangle
        canvas.style.outlineStyle = "none";
        (untyped canvas.style).webkitTapHighlightColor = "transparent";

        // Browser optimization hints
#if !flambe_transparent
        canvas.setAttribute("moz-opaque", "true");
#end
        // canvas.style.webkitTransform = "translateZ(0)";
        // canvas.style.backgroundColor = "#000";

        _stage = new HtmlStage(canvas);
        _pointer = new BasicPointer();
        _mouse = new HtmlMouse(_pointer, canvas);

        _renderer = createRenderer(canvas);

        mainLoop = new MainLoop();

        // Used by browsers that don't support audio very well
        musicPlaying = false;

        _canvas = canvas;
        _container = canvas.parentElement;
        _container.style.overflow = "hidden";
        _container.style.position = "relative";

        // Prevent double tap zooming on IE10. Maybe this should be in the MSPointer block below,
        // but I have no idea without testing, so apply it always
        // http://msdn.microsoft.com/en-us/library/windows/apps/Hh767313.aspx
        (untyped _container.style).msTouchAction = "none";

        var lastTouchTime = 0;
        var onMouse = function (event :MouseEvent) {
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
                    canvas.focus();
                }

            case "mousemove":
                _mouse.submitMove(x, y);

            case "mouseup":
                _mouse.submitUp(x, y, event.button);

            case "mousewheel", "DOMMouseScroll":
                var velocity = (event.type == "mousewheel") ? (untyped event).wheelDelta/40 : -event.detail;
                if (_mouse.submitScroll(x, y, velocity)) {
                    // Only prevent page scrolling if the event was handled
                    event.preventDefault();
                }
            }
        };
        // Add listeners on the window object so dragging and releasing outside of the canvas works
        Browser.window.addEventListener("mousedown", onMouse, false);
        Browser.window.addEventListener("mousemove", onMouse, false);
        Browser.window.addEventListener("mouseup", onMouse, false);

        // But the wheel listener should only go on the canvas
        canvas.addEventListener("mousewheel", onMouse, false);
        canvas.addEventListener("DOMMouseScroll", onMouse, false); // https://bugzil.la/719320

        // Suppress the context menu so right-click events aren't interfered with
        canvas.addEventListener("contextmenu", function (event) event.preventDefault(), false);

        // Detect touch support. See http://modernizr.github.com/Modernizr/touch.html for more
        // sophisticated detection methods, but this seems to cover all important browsers
        var standardTouch :Bool = untyped __js__("typeof")(Browser.window.ontouchstart) != "undefined";

        // The pointer event handles mouse movement, touch events, and stylus events.
        // We check to see if multiple points are supported indicating true touch support.
        // http://blogs.msdn.com/b/ie/archive/2011/10/19/handling-multi-touch-and-mouse-input-in-all-browsers.aspx
        var msTouch :Bool = untyped __js__("'msMaxTouchPoints' in window.navigator && (window.navigator.msMaxTouchPoints > 1)");

        if (standardTouch || msTouch) {
            var basicTouch = new BasicTouch(_pointer, standardTouch ?
                4 : (untyped Browser.navigator).msMaxTouchPoints);
            _touch = basicTouch;

            var onTouch = function (event :Dynamic) {
                var changedTouches :Array<Dynamic> = standardTouch ? event.changedTouches : [event];
                var bounds = event.target.getBoundingClientRect();
                lastTouchTime = event.timeStamp;

                switch (event.type) {
                case "touchstart", "MSPointerDown", "pointerdown":
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

                case "touchmove", "MSPointerMove", "pointermove":
                    event.preventDefault();
                    for (touch in changedTouches) {
                        var x = getX(touch, bounds);
                        var y = getY(touch, bounds);
                        var id = Std.int(standardTouch ? touch.identifier : touch.pointerId);
                        basicTouch.submitMove(id, x, y);
                    }

                case "touchend", "touchcancel", "MSPointerUp", "pointerup":
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

        // Handle uncaught errors
        var oldErrorHandler = (untyped Browser.window).onerror;
        (untyped Browser.window).onerror = function (message :String, url :String, line :Int) {
            System.uncaughtError.emit(message);
            return (oldErrorHandler != null) ? oldErrorHandler(message, url, line) : false;
        };

        // Handle visibility changes if the browser supports them
        // http://www.w3.org/TR/page-visibility/
        var hiddenApi = HtmlUtil.loadExtension("hidden", Browser.document);
        if (hiddenApi.value != null) {
            var onVisibilityChanged = function (_) {
                System.hidden._ = Reflect.field(Browser.document, hiddenApi.field);
            };
            onVisibilityChanged(null); // Update now
            Browser.document.addEventListener(hiddenApi.prefix + "visibilitychange",
                onVisibilityChanged, false);
        } else {
            // Adds some lock screen support for iOS, possibly other devices that don't support the
            // page visibility api.
            var onPageTransitionChange = function (event) {
                System.hidden._ = (event.type == "pagehide");
            };
            Browser.window.addEventListener("pageshow", onPageTransitionChange, false);
            Browser.window.addEventListener("pagehide", onPageTransitionChange, false);
        }

        // Skip the next frame when coming back from being hidden
        System.hidden.changed.connect(function (hidden,_) {
            if (!hidden) {
                _skipFrame = true;
            }
        });
        _skipFrame = false;

        _lastUpdate = HtmlUtil.now();

        // Use requestAnimationFrame if available, otherwise a 60 FPS setInterval
        // https://developer.mozilla.org/en/DOM/window.mozRequestAnimationFrame
        var requestAnimationFrame = HtmlUtil.loadExtension("requestAnimationFrame").value;
        if (requestAnimationFrame != null) {
            // Use the high resolution, monotonic timer if available
            // http://www.w3.org/TR/hr-time/
            var performance :Performance = Browser.window.performance;
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
            Browser.window.setInterval(function () {
                update(HtmlUtil.now());
            }, 16); // ~60 FPS
        }

#if debug
        new DebugLogic(this);
#if html
        _catapult = HtmlCatapultClient.canUse() ? new HtmlCatapultClient() : null;
#end
#end
        var promise = new Promise<Bool>();
        promise.success.connect(function (result) {
            Log.info("Initialized HTML platform", ["renderer", _renderer.type]);
        });
        promise.result = true;
        return promise;
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new HtmlAssetPackLoader(this, manifest).promise;
    }

    public function getStage () :StageSystem
    {
        return _stage;
    }

    public function getStorage () :StorageSystem
    {
        if (_storage == null) {
            // Safely access localStorage (browsers may throw an error on direct access)
            // http://dev.w3.org/html5/webstorage/#dom-localstorage
            var localStorage = Browser.getLocalStorage();
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
        var locale = Browser.navigator.language;
        if (locale == null) {
            // IE uses the non-standard userLanguage (or browserLanguage or systemLanguage, but
            // userLanguage seems to match String's locale-aware methods)
            locale = (untyped Browser.navigator).userLanguage;
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

    public function getCatapultClient ()
    {
        return _catapult;
    }

    private function update (now :Float)
    {
        var dt = (now-_lastUpdate) / 1000;
        _lastUpdate = now;

        if (System.hidden._) {
            return; // Prevent updates while hidden
        }
        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        mainLoop.render(_renderer);
    }

    public function getPointer () :PointerSystem
    {
        return _pointer;
    }

    public function getMouse () :MouseSystem
    {
        return _mouse;
    }

    public function getTouch () :TouchSystem
    {
        return _touch;
    }

    public function getKeyboard () :KeyboardSystem
    {
        if (_keyboard == null) {
            _keyboard = new BasicKeyboard();
            var onKey = function (event :KeyboardEvent) {
                switch (event.type) {
                case "keydown":
                    if (_keyboard.submitDown(event.keyCode)) {
                        event.preventDefault();
                    }
                case "keyup":
                    _keyboard.submitUp(event.keyCode);
                }
            };
            _canvas.addEventListener("keydown", onKey, false);
            _canvas.addEventListener("keyup", onKey, false);
        }
        return _keyboard;
    }

    public function getWeb () :WebSystem
    {
        if (_web == null) {
            _web = new HtmlWeb(_container);
        }
        return _web;
    }

    public function getExternal () :ExternalSystem
    {
        if (_external == null) {
            _external = new HtmlExternal();
        }
        return _external;
    }

    public function getMotion () :MotionSystem
    {
        if (_motion == null) {
            _motion = new HtmlMotion();
        }
        return _motion;
    }

    public function getRenderer () :InternalRenderer<Dynamic>
    {
        return _renderer;
    }

    private function getX (event :Dynamic, bounds :Dynamic) :Float
    {
        return (event.clientX - bounds.left)*_stage.width/bounds.width;
    }

    private function getY (event :Dynamic, bounds :Dynamic) :Float
    {
        return (event.clientY - bounds.top)*_stage.height/bounds.height;
    }

    private function createRenderer (canvas :CanvasElement) :InternalRenderer<Dynamic>
    {
#if !flambe_disable_webgl

#if firefox
        // WebGL is buggy in Firefox OS 1.1, so blacklist it there
        // https://developer.mozilla.org/en-US/docs/Gecko_user_agent_string_reference#Firefox_OS
        var majorVersion = ~/\bFirefox\/(\d+)/;
        if (!majorVersion.match(Browser.navigator.userAgent) || Std.parseInt(majorVersion.matched(1)) >= 26)
#end
        try {
            var gl = canvas.getContextWebGL(cast {
#if !flambe_transparent
                alpha: false,
#end
                depth: false,
                // http://blog.tojicode.com/2013/12/failifmajorperformancecaveat-with-great.html
                failIfMajorPerformanceCaveat: true,
            });
            if (gl != null) {
#if !flambe_disable_canvas
                // TODO(bruno): Remove this check once failIfMajorPerformanceCaveat becomes
                // prevalent
                if (HtmlUtil.detectSlowDriver(gl)) {
                    Log.warn("Detected a slow WebGL driver, falling back to canvas");
                } else
#end
                return new WebGLRenderer(_stage, gl);
            }
        } catch (_ :Dynamic) {
            // Getting the WebGL context blows up on some (headless?) systems
        }
#end

#if !flambe_disable_canvas
        // No WebGL, fall back to canvas
        return new CanvasRenderer(canvas);
#end

#if (flambe_disable_webgl && flambe_disable_canvas)
#error "Build with either flambe_disable_webgl or flambe_disable_canvas, not both!"
#end
        Log.error("No renderer available!");
        return null;
    }

    // Statically initialized subsystems
    private var _mouse :HtmlMouse;
    private var _pointer :BasicPointer;
    private var _renderer :InternalRenderer<Dynamic>;
    private var _stage :HtmlStage;
    private var _touch :TouchSystem;

    // Lazily initialized subsystems
    private var _external :ExternalSystem;
    private var _keyboard :BasicKeyboard;
    private var _motion :MotionSystem;
    private var _storage :StorageSystem;
    private var _web :WebSystem;

    private var _canvas :CanvasElement;
    private var _container :Element;

    private var _lastUpdate :Float;
    private var _skipFrame :Bool;

    private var _catapult :HtmlCatapultClient;
}
