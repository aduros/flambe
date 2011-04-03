package flambe.platform.flash;

import flash.Lib;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;

import flambe.asset.AssetPackLoader;
import flambe.display.Texture;
import flambe.Entity;
import flambe.FrameVisitor;
import flambe.Input;
import flambe.platform.AppDriver;
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

        _root = root;
        _screen = new BitmapData(stage.stageHeight, stage.stageHeight, false);
        _frameVisitor = new FrameVisitor(new FlashDrawingContext(_screen));

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

    private function createFlambeMouseEvent (event :MouseEvent) :flambe.display.MouseEvent
    {
        var f = new flambe.display.MouseEvent();
        f.viewX = event.stageX;
        f.viewY = event.stageY;
        return f;
    }

    private function onEnterFrame (_)
    {
        _screen.lock();
        _screen.fillRect(new flash.geom.Rectangle(0, 0, _screen.width, _screen.height), 0xc0c0c0);

        var now = Lib.getTimer();
        _frameVisitor.init(now - _lastUpdate);
        _lastUpdate = now;
        _root.visit(_frameVisitor);

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

    private var _screen :BitmapData;
    private var _root :Entity;
    private var _frameVisitor :FrameVisitor;
    private var _lastUpdate :Int;
}
