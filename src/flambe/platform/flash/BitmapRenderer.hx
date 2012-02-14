//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.Lib;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class BitmapRenderer
    implements Renderer
{
    public function new ()
    {
        var stage = Lib.current.stage;

        _bitmap = new Bitmap();
        stage.addChild(_bitmap);

        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }

    public function uploadTexture (texture :Texture)
    {
        // Nothing
    }

    public function willRender () :DrawingContext
    {
        _screen.lock();
        return _drawCtx;
    }

    public function didRender ()
    {
        _screen.unlock();
    }

    private function onResize (_)
    {
        if (_screen != null) {
            _screen.dispose();
        }

        var width = _bitmap.stage.stageWidth;
        var height = _bitmap.stage.stageHeight;
        if (width == 0 || height == 0) {
            // In IE, stageWidth and height may initialized to zero! A resize event will come in
            // after a couple frames to give us the real dimensions, use a fixed size until then.
            // http://jodieorourke.com/view.php?id=79&blog=news
            width = height = 100;
        }

        _screen = new BitmapData(width, height, false);
        _drawCtx = new BitmapDrawingContext(_screen);
        _bitmap.bitmapData = _screen;
    }

    private var _screen :BitmapData;
    private var _bitmap :Bitmap;
    private var _drawCtx :DrawingContext;
}
