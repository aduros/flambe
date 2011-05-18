package flambe.platform.amity;

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
        (untyped __amity).events.onEnterFrame = function (dt :Int) {
            loop.runFrame(dt);
        };

        var createMouseEvent = function (data) {
            var event = new MouseEvent();
            event.viewX = data.x;
            event.viewY = data.y;
            return event;
        };
        (untyped __amity).events.onMouseDown = function (event) {
            Input.mouseDown.emit(createMouseEvent(event));
        };
        (untyped __amity).events.onMouseMove = function (event) {
            Input.mouseMove.emit(createMouseEvent(event));
        };
        (untyped __amity).events.onMouseUp = function (event) {
            Input.mouseUp.emit(createMouseEvent(event));
        };
    }

    public function loadAssetPack (url :String) :AssetPackLoader
    {
        return new AmityAssetPackLoader(url);
    }

    public function getStageWidth () :Int
    {
        return (untyped __amity).canvas.WIDTH;
    }

    public function getStageHeight () :Int
    {
        return (untyped __amity).canvas.HEIGHT;
    }
}
