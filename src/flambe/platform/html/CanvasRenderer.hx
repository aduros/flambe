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
        return _drawCtx;
    }

    public function didRender ()
    {
        // Nothing
    }

    private var _drawCtx :CanvasDrawingContext;
}
