//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import haxe.io.Bytes;

import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.Rectangle;

class CanvasTexture
    implements Texture
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var graphics (get, null) :Graphics;

    // The Image (or sometimes Canvas) used for most draw calls
    public var image (default, null) :Dynamic;

    // The CanvasPattern required for drawPattern, lazily created on demand
    public var pattern :CanvasPattern;

    public function new (image :Dynamic)
    {
        this.image = image;
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        var data :Array<Int> = cast getContext2d().getImageData(x, y, width, height).data;
        return Bytes.ofData(data);
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
        ctx2d.putImageData(imageData, x, y);
        dirtyContents();
    }

    public function getColorBounds(mask :Int, color :Int, negate = false) :Rectangle
    {
        var data :Array<Int> = cast getContext2d().getImageData(0, 0, width, height).data;
        var bounds = [ width, height, 0, 0 ];

        // We need to split the check in two as left shifting in JS is contrained to 32 bits
        var masks = [ mask >>> 16, mask & 0xffff ];
        var targets = [ (color >>> 16) & masks[0], color & masks[1] ];

        var i = 0;
        while(i < data.length) {
            if( ((data[i + 3] << 8) + data[i])     & masks[0] == targets[0] &&
                ((data[i + 1] << 8) + data[i + 2]) & masks[1] == targets[1] ) {
                if(negate) {
                    i += 4;
                    continue;
                }
            } else {
                if(!negate) {
                    i += 4;
                    continue;
                }
            }

            var x = Std.int(i / 4) % width;
            var y = Std.int(Std.int(i / 4) / width);

            if(x < bounds[0]) bounds[0] = x;
            if(x > bounds[2]) bounds[2] = x;

            if(y < bounds[1]) bounds[1] = y;
            if(y > bounds[3]) bounds[3] = y;

            i += 4;
        }

        if(bounds[2] == 0 || bounds[3] == 0)
          return new Rectangle(0, 0, 0, 0);
        else
          return new Rectangle(bounds[0], bounds[1], bounds[2] - bounds[0] + 1, bounds[3] - bounds[1] + 1);
    }

    inline public function dirtyContents ()
    {
        pattern = null;
    }

    inline private function get_width () :Int
    {
        return image.width;
    }

    inline private function get_height () :Int
    {
        return image.height;
    }

    private function get_graphics () :CanvasGraphics
    {
        if (_graphics == null) {
            getContext2d(); // Force conversion
            _graphics = new InternalGraphics(this);
        }
        return _graphics;
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
        return image.getContext2d();
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
