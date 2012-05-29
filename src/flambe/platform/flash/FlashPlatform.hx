//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

#if flash11_2 import flash.events.ThrottleEvent; #end
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
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
import flambe.input.KeyEvent;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
import flambe.platform.Platform;
import flambe.platform.BasicKeyboard;
import flambe.platform.BasicPointer;
import flambe.platform.MainLoop;
import flambe.storage.Storage;
import flambe.util.Logger;
import flambe.util.Promise;

class FlashPlatform
    implements Platform
{
    private static var log :Logger; // This needs to be initialized later

    public var stage (getStage, null) :Stage;
    public var storage (getStorage, null) :Storage;
    public var pointer (getPointer, null) :Pointer;
    public var keyboard (getKeyboard, null) :Keyboard;
    public var locale (getLocale, null) :String;

    public var mainLoop (default, null) :MainLoop;
    public var renderer :Renderer;

    public static var instance /*(default, null)*/ = new FlashPlatform();

    private function new ()
    {
    }

    public function init ()
    {
        log = Log.log;
        log.info("Initializing Flash platform");

        var stage = Lib.current.stage;

        _stage = new FlashStage(stage);
        _pointer = new BasicPointer();
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
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
            UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

#if flash11_2
        // TODO(bruno): ThrottleEvent may not be exactly right, but VisibilityEvent is broken and
        // Event.ACTIVATE only handles focus
        stage.addEventListener(ThrottleEvent.THROTTLE, onThrottle);
        // TODO(bruno): Get the currently throttled state when the app starts?
#end

        _lastUpdate = Lib.getTimer();
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
                log.warn("SharedObject is unavailable, falling back to unpersisted storage");
                _storage = new DummyStorage();
            }
        }
        return _storage;
    }

    public function getPointer () :Pointer
    {
        return _pointer;
    }

    public function getKeyboard () :Keyboard
    {
        return _keyboard;
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
#if !flambe_disable_logging
        return new FlashLogHandler(tag);
#else
        return null;
#end
    }

    private function onMouseDown (event :MouseEvent)
    {
        _pointer.submitDown(new PointerEvent(event.stageX, event.stageY));
    }

    private function onMouseMove (event :MouseEvent)
    {
        _pointer.submitMove(new PointerEvent(event.stageX, event.stageY));
    }

    private function onMouseUp (event :MouseEvent)
    {
        _pointer.submitUp(new PointerEvent(event.stageX, event.stageY));
    }

    private function onKeyDown (event :KeyboardEvent)
    {
        _keyboard.submitDown(new KeyEvent(event.charCode));
    }

    private function onKeyUp (event :KeyboardEvent)
    {
        _keyboard.submitUp(new KeyEvent(event.charCode));
    }

    private function onEnterFrame (_)
    {
        var now = Lib.getTimer();
        var dt = (now - _lastUpdate)/1000;
        _lastUpdate = now;

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

    private static var _instance :FlashPlatform;

    private var _stage :Stage;
    private var _pointer :BasicPointer;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;

    private var _lastUpdate :Int;
}
