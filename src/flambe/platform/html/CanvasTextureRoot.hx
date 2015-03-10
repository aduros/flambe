//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import haxe.io.Bytes;
import haxe.io.BytesData;

import flambe.display.Graphics;
import flambe.display.Texture;

class CanvasTextureRoot extends BasicAsset<CanvasTextureRoot>
    implements TextureRoot
{
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    // The Image (or sometimes Canvas) used for most draw calls
    public var image (default, null) :Dynamic;

    public var updateCount :Int = 0;

    public function new (image :Dynamic)
    {
        super();
        this.image = image;
        width = image.width;
        height = image.height;
    }

    public function createTexture (width :Int, height :Int) :CanvasTexture
    {
        return new CanvasTexture(this, width, height);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        assertNotDisposed();

        return Bytes.ofData(cast getContext2d().getImageData(x, y, width, height).data);
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        assertNotDisposed();

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
        ctx2d.putImageData(imageData, x, y);
        dirtyContents();
    }

    // Invalidates the cached patterns of all textures using this root
    inline public function dirtyContents ()
    {
        ++updateCount;
    }

    public function getGraphics () :CanvasGraphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            getContext2d(); // Force conversion
            _graphics = new InternalGraphics(this);
        }
        return _graphics;
    }

    public function createPattern (x :Int, y :Int, width :Int, height :Int) :CanvasPattern
    {
        var ctx2d = getContext2d();
        var source = image;
        if (x != 0 || y != 0 || width != this.width || height != this.height) {
            // Create a temporary canvas if the size doesn't match this root
            source = HtmlUtil.createEmptyCanvas(width, height);
            var crop = source.getContext2d();
            crop.globalCompositeOperation = "copy";
            crop.drawImage(image, -x, -y);
        }
        return ctx2d.createPattern(source, "repeat");
    }

    private function getContext2d () :CanvasRenderingContext2D
    {
        // Convert the image to a canvas when necessary. Why not have the image be a canvas to
        // begin with, you ask? Some browsers (notably Android 4) render canvases a LOT slower
        // than image elements, so we avoid using a canvas unless absolutely necessary. One day
        // when Android's browser joins the modern age, this can be simplified.
        // http://jsperf.com/canvas-drawimage
        if (!Std.is(image, CanvasElement)) {
            image = HtmlUtil.createCanvas(image);
        }
        var canvas :CanvasElement = cast image;
        return canvas.getContext2d();
    }

    override private function copyFrom (that :CanvasTextureRoot)
    {
        this.image = that.image;
        this._graphics = that._graphics;
        dirtyContents();
    }

    override private function onDisposed ()
    {
        image = null;
        _graphics = null;
    }

    private var _graphics :CanvasGraphics = null;
}

// A Graphics that invalidates its texture's cached pattern after every draw call
private class InternalGraphics extends CanvasGraphics
{
    public function new (renderTarget :CanvasTextureRoot)
    {
        super(renderTarget.image, true);
        _renderTarget = renderTarget;
    }

    override public function drawTexture (texture :Texture, x :Float, y :Float)
    {
        super.drawTexture(texture, x, y);
        _renderTarget.dirtyContents();
    }

    override public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        super.drawSubTexture(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
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

    private var _renderTarget :CanvasTextureRoot;
}
