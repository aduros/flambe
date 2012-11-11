//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class CanvasRenderer
    implements Renderer
{
    public function new (canvas :Dynamic)
    {
        _drawCtx = new CanvasDrawingContext(canvas);
    }

    public function uploadTexture (texture :Texture)
    {
        // Nothing
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

    private var _drawCtx :CanvasDrawingContext;
}
