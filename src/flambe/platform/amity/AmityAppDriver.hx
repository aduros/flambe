package flambe.platform.amity;

import amity.Canvas;
import amity.Events;

import flambe.asset.AssetPackLoader;
import flambe.display.MouseEvent;
import flambe.display.Texture;
import flambe.Entity;
import flambe.Input;
import flambe.platform.AppDriver;
import flambe.platform.MainLoop;

class AmityAppDriver
    implements AppDriver
{
    public function new ()
    {
    }

    public function init (root :Entity)
    {
#if debug
        // Redirect traces to Amity
        haxe.Log.trace = (untyped __amity).log;
#end
        var loop = new MainLoop(new AmityDrawingContext());
        Events.onEnterFrame = function (dt) {
            loop.runFrame(dt);
        };

        var createMouseEvent = function (data) {
            var event = new MouseEvent();
            event.viewX = data.x;
            event.viewY = data.y;
            return event;
        };
        Events.onMouseDown = function (event) {
            Input.mouseDown.emit(createMouseEvent(event));
        };
        Events.onMouseMove = function (event) {
            Input.mouseMove.emit(createMouseEvent(event));
        };
        Events.onMouseUp = function (event) {
            Input.mouseUp.emit(createMouseEvent(event));
        };
    }

    public function loadAssetPack (url :String) :AssetPackLoader
    {
        return new AmityAssetPackLoader(url);
    }

    public function getStageWidth () :Int
    {
        return Canvas.WIDTH;
    }

    public function getStageHeight () :Int
    {
        return Canvas.HEIGHT;
    }
}
