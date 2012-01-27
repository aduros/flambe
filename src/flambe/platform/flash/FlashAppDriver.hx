//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
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
import flambe.input.Input;
import flambe.input.KeyEvent;
import flambe.input.PointerEvent;
import flambe.platform.AppDriver;
import flambe.platform.BasicInput;
import flambe.platform.MainLoop;
import flambe.util.Promise;

class FlashAppDriver
    implements AppDriver
{
    public var stage (getStage, null) :Stage;
    public var storage (getStorage, null) :Storage;
    public var input (getInput, null) :Input;
    public var locale (getLocale, null) :String;

    public function new ()
    {
    }

    public function init (root :Entity)
    {
#if debug
        haxe.Log.trace = function (v, ?pos) {
            flash.Lib.trace(v);
        };
#end
        var stage = Lib.current.stage;

        _stage = new FlashStage(stage);
        _stage.resize.connect(onResized);
        onResized();

        _input = new BasicInput();

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
                // SharedObject.getLocal may throw an error, fall back to temporary storage
                _storage = new DummyStorage();
            }
        }
        return _storage;
    }

    public function getInput () :Input
    {
        return _input;
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
        _input.pointerDown.emit(new PointerEvent(event.stageX, event.stageY));
    }

    private function onMouseMove (event :MouseEvent)
    {
        _input.pointerMove.emit(new PointerEvent(event.stageX, event.stageY));
    }

    private function onMouseUp (event :MouseEvent)
    {
        _input.pointerUp.emit(new PointerEvent(event.stageX, event.stageY));
    }

    private function onKeyDown (event :KeyboardEvent)
    {
        if (!_input.isKeyDown(event.charCode)) {
            _input.keyDown.emit(new KeyEvent(event.charCode));
        }
    }

    private function onKeyUp (event :KeyboardEvent)
    {
        if (_input.isKeyDown(event.charCode)) {
            _input.keyUp.emit(new KeyEvent(event.charCode));
        }
    }

    private function onEnterFrame (_)
    {
        var now = Lib.getTimer();
        var dt = now - _lastUpdate;

        _lastUpdate = now;

        _loop.update(dt);
        Lib.current.stage.invalidate();
    }

    private function onRender (_)
    {
        _screen.lock();
        _loop.render();
        _screen.unlock();
    }

    private function onResized ()
    {
        _screen = new BitmapData(_stage.width, _stage.height, false);
        _loop = new MainLoop(new FlashDrawingContext(_screen));

        if (_bitmap != null) {
            Lib.current.removeChild(_bitmap);
        }
        _bitmap = new Bitmap(_screen);
        Lib.current.addChild(_bitmap);
    }

    private function onUncaughtError (event :Event)
    {
        // More reflection here because I don't want to require Flash 10.1...
        var error = Reflect.field(event, "error");
        System.uncaughtError.emit(FlashUtil.getErrorMessage(error));
    }

    private var _bitmap :Bitmap;

    private var _screen :BitmapData;
    private var _loop :MainLoop;
    private var _lastUpdate :Int;

    private var _stage :Stage;
    private var _input :Input;
    private var _storage :Storage;
}
