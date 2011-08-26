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
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.SharedObject;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.ui.Mouse;

import flambe.asset.AssetPackLoader;
import flambe.display.Texture;
import flambe.Entity;
import flambe.Input;
import flambe.platform.AppDriver;
import flambe.platform.MainLoop;
import flambe.System;

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
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        // Look up Mouse.supportsCursor reflectively, because it's not worth depending on Flash 10.1
        var supportsCursor = !Reflect.hasField(Mouse, "supportsCursor")
            || Reflect.field(Mouse, "supportsCursor");
        if (Capabilities.playerType == "PlugIn" && !supportsCursor) {
            // Probably running in a mobile browser
            stage.addEventListener(MouseEvent.MOUSE_DOWN, handleFullScreen);
        }

        // Hide the junk in the right click menu
        var menu = new ContextMenu();
        menu.hideBuiltInItems();
        Lib.current.contextMenu = menu;

        _lastUpdate = Lib.getTimer();
    }

    public function loadAssetPack (url :String) :AssetPackLoader
    {
        return new FlashAssetPackLoader(url);
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

    private function onMouseDown (event :MouseEvent)
    {
        Input.mouseDown.emit(createFlambeMouseEvent(event));
    }

    private function onMouseMove (event :MouseEvent)
    {
        Input.mouseMove.emit(createFlambeMouseEvent(event));
    }

    private function onMouseUp (event :MouseEvent)
    {
        Input.mouseUp.emit(createFlambeMouseEvent(event));
    }

    private static function createFlambeMouseEvent (event :MouseEvent) :flambe.display.MouseEvent
    {
        var f = new flambe.display.MouseEvent();
        f.viewX = event.stageX;
        f.viewY = event.stageY;
        return f;
    }

    private function onEnterFrame (_)
    {
        var now = Lib.getTimer();
        var dt = now - _lastUpdate;

        _lastUpdate = now;

        _screen.lock();
        _loop.runFrame(dt);
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
    private var _screen :BitmapData;
    private var _loop :MainLoop;
    private var _lastUpdate :Int;
    private var _storage :Storage;
}
