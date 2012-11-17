//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class CanvasRenderer
    implements Renderer
{
    public function new (canvas :Dynamic)
    {
        _drawCtx = new CanvasDrawingContext(canvas);
    }

    public function createTexture (image :Dynamic) :Texture
    {
        var texture = new HtmlTexture();
        if (CANVAS_TEXTURES) {
            var canvas :Dynamic = Lib.document.createElement("canvas");
            canvas.width = image.width;
            canvas.height = image.height;
            canvas.getContext("2d").drawImage(image, 0, 0);
            texture.image = canvas;
        } else {
            texture.image = image;
        }
        return texture;
    }

    public function willRender () :DrawingContext
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
        _inspector = new InspectorDrawingContext(_drawCtx);
    }
    private var _inspector :InspectorDrawingContext;
#end

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool = (function () {
        // On iOS, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/8
        var pattern = ~/(iPhone|iPod|iPad)/;
        return pattern.match(Lib.window.navigator.userAgent);
    })();

    private var _drawCtx :CanvasDrawingContext;
}
