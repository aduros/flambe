//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import haxe.io.Bytes;

import flambe.display.Graphics;
import flambe.display.Texture;

class CanvasTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;
    public var graphics (getGraphics, null) :Graphics;

    // The Image (or sometimes Canvas) used for most draw calls
    public var image (default, null) :Dynamic;

    // The CanvasPattern required for drawPattern, lazily created on demand
    public var pattern :Dynamic;

    public function new (image :Dynamic)
    {
        this.image = image;
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        return Bytes.ofData(getContext2d().getImageData(x, y, width, height).data);
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        var ctx2d = getContext2d();
        var imageData = ctx2d.createImageData(sourceW, sourceH);
        var data :Dynamic = imageData.data;
        if (data.set != null) {
            // Data is a Uint8ClampedArray, copy it in one swoop
            data.set(pixels.getData());
        } else {
            // Data is a normal array, copy it manually
            var size = 4*sourceW*sourceH;
            for (ii in 0...size) {
                data[ii] = pixels.get(ii);
            }
        }

        // Draw the pixels, and invalidate our contents
        ctx2d.putImageData(imageData, x, y, 0, 0, sourceW, sourceH);
        dirtyContents();
    }

    inline public function dirtyContents ()
    {
        pattern = null;
    }

    inline private function getWidth () :Int
    {
        return image.width;
    }

    inline private function getHeight () :Int
    {
        return image.height;
    }

    private function getGraphics () :CanvasGraphics
    {
        if (_graphics == null) {
            getContext2d(); // Force conversion
            _graphics = new InternalGraphics(this);
        }
        return _graphics;
    }

    private function getContext2d () :Dynamic
    {
        // Convert the image to a canvas when necessary. Why not have the image be a canvas to
        // begin with, you ask? Some browsers (notably Android 4) render canvases a LOT slower
        // than image elements, so we avoid using a canvas unless absolutely necessary. One day
        // when Android's browser joins the modern age, this can be simplified.
        // http://jsperf.com/canvas-drawimage
        if (!Std.is(image, untyped HTMLCanvasElement)) {
            image = HtmlUtil.createCanvas(image);
        }
        return image.getContext("2d");
    }

    private var _graphics :CanvasGraphics = null;
}

// A Graphics that invalidates its texture's cached pattern after every draw call
private class InternalGraphics extends CanvasGraphics
{
    public function new (renderTarget :CanvasTexture)
    {
        super(renderTarget.image);
        _renderTarget = renderTarget;
    }

    override public function drawImage (texture :Texture, x :Float, y :Float)
    {
        super.drawImage(texture, x, y);
        _renderTarget.dirtyContents();
    }

    override public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        super.drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
        _renderTarget.dirtyContents();
    }

    override public function drawPattern (texture :Texture, x :Float, y :Float,
        width :Float, height :Float)
    {
        super.drawPattern(texture, x, y, width, height);
        _renderTarget.dirtyContents();
    }

    override public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        super.fillRect(color, x, y, width, height);
        _renderTarget.dirtyContents();
    }

    private var _renderTarget :CanvasTexture;
}
