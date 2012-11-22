//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class CanvasTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;
    public var ctx (getContext, null) :DrawingContext;

    // The Image (or sometimes Canvas) used for most draw calls
    public var image (default, null) :Dynamic;

    // The CanvasPattern required for drawPattern, lazily created on demand
    public var pattern :Dynamic;

    public function new (image :Dynamic)
    {
        this.image = image;
    }

    inline private function getWidth () :Int
    {
        return image.width;
    }

    inline private function getHeight () :Int
    {
        return image.height;
    }

    private function getContext () :CanvasDrawingContext
    {
        if (_ctx == null) {
            // Convert the image to a canvas if necessary. Why not have the image be a canvas to
            // begin with, you ask? Some browsers (notably Android 4) render canvases a LOT slower
            // than image elements, so we avoid using a canvas unless absolutely necessary. One day
            // when Android's browser joins the modern age, this can be simplified.
            // http://jsperf.com/canvas-drawimage
            if (!Std.is(image, untyped HTMLCanvasElement)) {
                image = HtmlUtil.createCanvas(image);
            }
            _ctx = new InternalDrawingContext(this);
        }
        return _ctx;
    }

    private var _ctx :CanvasDrawingContext = null;
}

// A DrawingContext that invalidates its texture's cached pattern after every draw call
private class InternalDrawingContext extends CanvasDrawingContext
{
    public function new (renderTarget :CanvasTexture)
    {
        super(renderTarget.image);
        _renderTarget = renderTarget;
    }

    override public function drawImage (texture :Texture, x :Float, y :Float)
    {
        super.drawImage(texture, x, y);
        clearPattern();
    }

    override public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        super.drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
        clearPattern();
    }

    override public function drawPattern (texture :Texture, x :Float, y :Float,
        width :Float, height :Float)
    {
        super.drawPattern(texture, x, y, width, height);
        clearPattern();
    }

    override public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        super.fillRect(color, x, y, width, height);
        clearPattern();
    }

    inline private function clearPattern ()
    {
        _renderTarget.pattern = null;
    }

    private var _renderTarget :CanvasTexture;
}
