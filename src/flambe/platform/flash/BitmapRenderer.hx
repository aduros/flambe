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
        _screen = new BitmapData(_bitmap.stage.stageWidth, _bitmap.stage.stageWidth, false);
        _drawCtx = new BitmapDrawingContext(_screen);
        _bitmap.bitmapData = _screen;
    }

    private var _screen :BitmapData;
    private var _bitmap :Bitmap;
    private var _drawCtx :DrawingContext;
}
