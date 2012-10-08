//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.events.UncaughtErrorEvent;
import nme.external.ExternalInterface;
import nme.Lib;
import nme.net.SharedObject;
import nme.system.Capabilities;

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

class NMEPlatform
    implements Platform
{
    private static var log :Logger; // This needs to be initialized later

    public static var instance (default, null) :NMEPlatform = new NMEPlatform();

    public var mainLoop (default, null) :MainLoop;
    public var renderer :Renderer;

    private function new ()
    {
    }

    public function init ()
    {
        log = Log.log;
        log.info("Initializing NME platform");

        var stage = Lib.current.stage;

        _stage = new NMEStage(stage);
        _pointer = new BasicPointer();
        _mouse = NMEMouse.shouldUse() ? new NMEMouse(_pointer, stage) : new DummyMouse();
        _touch = NMETouch.shouldUse() ? new NMETouch(_pointer, stage) : new DummyTouch();
        _keyboard = new BasicKeyboard();

        renderer = new BitmapRenderer();
        mainLoop = new MainLoop();

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RENDER, onRender);

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        _lastUpdate = Lib.getTimer();
        _skipFrame = false;
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new NMEAssetPackLoader(manifest).promise;
    }

    public function getStage () :Stage
    {
        return _stage;
    }

    public function getStorage () :Storage
    {
        if (_storage == null) {
            try {
                _storage = new NMEStorage(SharedObject.getLocal("flambe"));
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
            _web = new NMEWeb();
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
        return new NMELogHandler(tag);
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

#if flash11_2
    /*private function onThrottle (event :ThrottleEvent)
    {
        System.hidden._ = (event.state != "resume");
    }*/
#end

    private var _stage :NMEStage;
    private var _pointer :BasicPointer;
    private var _mouse :Mouse;
    private var _touch :Touch;
    private var _keyboard :BasicKeyboard;
    private var _storage :Storage;
    private var _web :Web;

    private var _lastUpdate :Int;
    private var _skipFrame :Bool;
}
