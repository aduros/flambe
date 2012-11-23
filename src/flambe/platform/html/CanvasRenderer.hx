//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.Graphics;
import flambe.display.Texture;

class CanvasRenderer
    implements Renderer
{
    public function new (canvas :Dynamic)
    {
        _drawCtx = new CanvasGraphics(canvas);
        _drawCtx.clear();
    }

    public function createTexture (image :Dynamic) :Texture
    {
        return new CanvasTexture(CANVAS_TEXTURES ? HtmlUtil.createCanvas(image) : image);
    }

    public function createEmptyTexture (width :Int, height :Int) :Texture
    {
        var canvas :Dynamic = Lib.document.createElement("canvas");
        canvas.width = width;
        canvas.height = height;
        return new CanvasTexture(canvas);
    }

    public function willRender () :Graphics
    {
        _drawCtx.willRender();
#if debug
        return (_inspector != null) ? _inspector : _drawCtx;
#else
        return _drawCtx;
#end
    }

    public function didRender ()
    {
#if debug
        if (_inspector != null) {
            _inspector.show();
            _inspector = null;
        }
#end
    }

#if debug
    public function inspectNextFrame ()
    {
        _inspector = new InspectorGraphics(_drawCtx);
    }
    private var _inspector :InspectorGraphics;
#end

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool = (function () {
        // On iOS, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/8
        var pattern = ~/(iPhone|iPod|iPad)/;
        return pattern.match(Lib.window.navigator.userAgent);
    })();

    private var _drawCtx :CanvasGraphics;
}
