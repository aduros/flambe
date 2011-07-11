//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.SharedObject;

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
        var stage = Lib.current.stage;

        _screen = new BitmapData(stage.stageWidth, stage.stageHeight, false);
        _loop = new MainLoop(new FlashDrawingContext(_screen));

        Lib.current.addChild(new Bitmap(_screen));

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.scaleMode = NO_SCALE;

        _lastUpdate = Lib.getTimer();

#if debug
        //haxe.Log.trace = function (v, ?pos) {
        //    flash.Lib.trace(v);
        //};
#end
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

    private var _screen :BitmapData;
    private var _loop :MainLoop;
    private var _lastUpdate :Int;
    private var _storage :Storage;
}
