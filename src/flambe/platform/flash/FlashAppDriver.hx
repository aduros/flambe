//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.Lib;
import flash.net.SharedObject;
import flash.system.Capabilities;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.Entity;
import flambe.input.Keyboard;
import flambe.input.KeyEvent;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
import flambe.platform.AppDriver;
import flambe.platform.BasicKeyboard;
import flambe.platform.BasicPointer;
import flambe.platform.MainLoop;
import flambe.util.Promise;

class FlashAppDriver
    implements AppDriver
{
    public var stage (getStage, null) :Stage;
    public var storage (getStorage, null) :Storage;
    public var pointer (getPointer, null) :Pointer;
    public var keyboard (getKeyboard, null) :Keyboard;
    public var locale (getLocale, null) :String;

    public var mainLoop (default, null) :MainLoop;

    public static function getInstance () :FlashAppDriver
    {
        if (_instance == null) {
            _instance = new FlashAppDriver();
        }
        return _instance;
    }

    private function new ()
    {
        var stage = Lib.current.stage;

        _stage = new FlashStage(stage);
        _pointer = new BasicPointer();
        _keyboard = new BasicKeyboard();

        _renderer = new BitmapRenderer();
        mainLoop = new MainLoop(_renderer);

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RENDER, onRender);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        // Handle uncaught errors
        var loaderInfo = Lib.current.loaderInfo;
        if (Reflect.hasField(loaderInfo, "uncaughtErrorEvents")) {
            var dispatcher :IEventDispatcher = Reflect.field(loaderInfo, "uncaughtErrorEvents");
            dispatcher.addEventListener("uncaughtError", onUncaughtError);
        }

        _lastUpdate = Lib.getTimer();
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new FlashAssetPackLoader(manifest, _renderer).promise;
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
                // SharedObject.getLocal may throw an error, fall back to temporary storage
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
        var dt = now - _lastUpdate;

        _lastUpdate = now;

        mainLoop.update(dt);
        Lib.current.stage.invalidate();
    }

    private function onRender (_)
    {
        mainLoop.render();
    }

    private function onUncaughtError (event :Event)
    {
        // More reflection here because I don't want to require Flash 10.1...
        var error = Reflect.field(event, "error");
        System.uncaughtError.emit(FlashUtil.getErrorMessage(error));
    }

    private static var _instance :FlashAppDriver;

    private var _stage :Stage;
    private var _pointer :BasicPointer;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;

    private var _lastUpdate :Int;
    private var _renderer :Renderer;
}
