//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

#if flash11_2 import flash.events.ThrottleEvent; #end
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.events.UncaughtErrorEvent;
import flash.external.ExternalInterface;
import flash.Lib;
import flash.net.SharedObject;
import flash.system.Capabilities;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
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
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.web.Web;

class FlashPlatform
    implements Platform
{
    public static var instance (default, null) :FlashPlatform = new FlashPlatform();

    public var mainLoop (default, null) :MainLoop;
    public var renderer :Renderer;

    private function new ()
    {
    }

    public function init ()
    {
        Log.info("Initializing Flash platform");

        var stage = Lib.current.stage;

        _stage = new FlashStage(stage);
        _pointer = new BasicPointer();
        _mouse = FlashMouse.shouldUse() ? new FlashMouse(_pointer, stage) : new DummyMouse();

#if flambe_air
        _touch = AirTouch.shouldUse() ? new AirTouch(_pointer, stage) : new DummyTouch();
#else
        _touch = new DummyTouch();
#end

        _keyboard = new BasicKeyboard();

#if flash11
        var stage3DRenderer = new Stage3DRenderer();
        renderer = stage3DRenderer;
        stage3DRenderer.init();
#else
        renderer = new BitmapRenderer();
#end
        mainLoop = new MainLoop();

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RENDER, onRender);

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
            UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

#if flash11_2
        // TODO(bruno): ThrottleEvent may not be exactly right, but VisibilityEvent is broken and
        // Event.ACTIVATE only handles focus
        // TODO(bruno): Get the currently throttled state when the app starts?
        stage.addEventListener(ThrottleEvent.THROTTLE, onThrottle);
        System.hidden.changed.connect(function (hidden,_) {
            if (!hidden) {
                _skipFrame = true;
            }
        });
#end

        _lastUpdate = Lib.getTimer();
        _skipFrame = false;
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new FlashAssetPackLoader(manifest).promise;
    }

    public function getStage () :Stage
    {
        return _stage;
    }

    public function getStorage () :Storage
    {
        if (_storage == null) {
            try {
                _storage = new FlashStorage(SharedObject.getLocal("flambe"));
            } catch (err :Dynamic) {
                // SharedObject.getLocal may throw an error
                Log.warn("SharedObject is unavailable, falling back to unpersisted storage");
                _storage = new DummyStorage();
            }
        }
        return _storage;
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
#if flambe_air
            if (AirWeb.shouldUse()) {
                _web = new AirWeb(_stage.nativeStage);
            } else {
                Log.warn("StageWebView is unavailable");
                _web = new FlashWeb();
            }
#else
            _web = new FlashWeb();
#end
        }
        return _web;
    }

    public function getLocale () :String
    {
        return Capabilities.language;
    }

    public function callNative (funcName :String, params :Array<Dynamic>) :Dynamic
    {
        if (params == null) {
            params = [];
        }
        var args = [ cast funcName ].concat(params);
        return Reflect.callMethod(null, ExternalInterface.call, args);
    }

    public function createLogHandler (tag :String) :LogHandler
    {
#if (debug || flambe_keep_logs)
        return new FlashLogHandler(tag);
#else
        return null;
#end
    }

    private function onKeyDown (event :KeyboardEvent)
    {
        event.preventDefault();
        _keyboard.submitDown(event.keyCode);
    }

    private function onKeyUp (event :KeyboardEvent)
    {
        _keyboard.submitUp(event.keyCode);
    }

    private function onEnterFrame (_)
    {
        var now = Lib.getTimer();
        var dt = (now - _lastUpdate)/1000;
        _lastUpdate = now;

        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        Lib.current.stage.invalidate();
    }

    private function onRender (_)
    {
        mainLoop.render(renderer);
    }

    private function onUncaughtError (event :UncaughtErrorEvent)
    {
        System.uncaughtError.emit(FlashUtil.getErrorMessage(event.error));
    }

#if flash11_2
    private function onThrottle (event :ThrottleEvent)
    {
        System.hidden._ = (event.state != "resume");
    }
#end

    private var _stage :FlashStage;
    private var _pointer :BasicPointer;
    private var _mouse :Mouse;
    private var _touch :Touch;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;
    private var _web :Web;

    private var _lastUpdate :Int;
    private var _skipFrame :Bool;
}
