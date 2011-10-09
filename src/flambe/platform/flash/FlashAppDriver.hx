//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.Lib;
import flash.media.Video;
import flash.net.SharedObject;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.ui.Mouse;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.KeyEvent;
import flambe.display.Texture;
import flambe.Entity;
import flambe.Input;
import flambe.platform.AppDriver;
import flambe.platform.MainLoop;
import flambe.System;
import flambe.util.Promise;

class FlashAppDriver
    implements AppDriver
{
    public function new ()
    {
    }

    public function init (root :Entity)
    {
#if debug
        //haxe.Log.trace = function (v, ?pos) {
        //    flash.Lib.trace(v);
        //};
#end
        var stage = Lib.current.stage;

        stage.scaleMode = NO_SCALE;
        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RENDER, onRender);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        if (Capabilities.playerType == "PlugIn" && isMobile()) {
            // Probably running in a mobile browser
            stage.addEventListener(MouseEvent.MOUSE_DOWN, handleFullScreen);
        }

        // Hide the junk in the right click menu
        var menu = new ContextMenu();
        menu.hideBuiltInItems();
        Lib.current.contextMenu = menu;

        _lastUpdate = Lib.getTimer();
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new FlashAssetPackLoader(manifest).promise;
    }

    public function getStageWidth () :Int
    {
        return _screen.width;
    }

    public function getStageHeight () :Int
    {
        return _screen.height;
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

    public function lockOrientation (orient :Orientation)
    {
        if (!isMobile()) {
            return;
        }
        if (orient == null) {
            if (_orientHack != null) {
                _orientHack.parent.removeChild(_orientHack);
                _orientHack = null;
            }
            return;
        }

        // http://www.kongregate.com/pages/flash-sizing-zen#device_orientation
        // Only works in full screen. AIR has something less whack, but this works in the browser
        switch (orient) {
        case Portrait:
            // Unimplemented
        case Landscape:
            if (_orientHack == null) {
                _orientHack = new Video(0, 0);
                _orientHack.visible = false;
                Lib.current.addChild(_orientHack);
            }
        }
    }

    // Tries to guess if we're running on a mobile device
    private function isMobile ()
    {
        // Look up Mouse.supportsCursor reflectively, because it's not worth depending on Flash 10.1
        return Reflect.hasField(Mouse, "supportsCursor")
            && !Reflect.field(Mouse, "supportsCursor");
    }

    private function onMouseDown (event :MouseEvent)
    {
        Input.mouseDown.emit(new flambe.display.MouseEvent(event.stageX, event.stageY));
    }

    private function onMouseMove (event :MouseEvent)
    {
        Input.mouseMove.emit(new flambe.display.MouseEvent(event.stageX, event.stageY));
    }

    private function onMouseUp (event :MouseEvent)
    {
        Input.mouseUp.emit(new flambe.display.MouseEvent(event.stageX, event.stageY));
    }

    private function onKeyDown (event :KeyboardEvent)
    {
        if (!Input.isKeyDown(event.charCode)) {
            Input.keyDown.emit(new KeyEvent(event.charCode));
        }
    }

    private function onKeyUp (event :KeyboardEvent)
    {
        if (Input.isKeyDown(event.charCode)) {
            Input.keyUp.emit(new KeyEvent(event.charCode));
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

    private function onResize (_)
    {
        var stage = Lib.current.stage;
        _screen = new BitmapData(stage.stageWidth, stage.stageHeight, false);
        _loop = new MainLoop(new FlashDrawingContext(_screen));

        if (_bitmap != null) {
            Lib.current.removeChild(_bitmap);
        }
        _bitmap = new Bitmap(_screen);
        Lib.current.addChild(_bitmap);
    }

    private function handleFullScreen (_)
    {
        Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN;
    }

    private var _bitmap :Bitmap;
    private var _orientHack :Video;

    private var _screen :BitmapData;
    private var _loop :MainLoop;
    private var _lastUpdate :Int;

    private var _storage :Storage;
}
