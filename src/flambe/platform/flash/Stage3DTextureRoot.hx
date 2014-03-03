//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Vector;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxe.io.Bytes;

import flambe.math.FMath;

class Stage3DTextureRoot extends BasicAsset<Stage3DTextureRoot>
    implements TextureRoot
{
    // The power of two dimensions of the texture
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    public var nativeTexture (default, null) :flash.display3D.textures.Texture;

    public function new (renderer :Stage3DRenderer, width :Int, height :Int)
    {
        super();
        _renderer = renderer;
        // 1 px textures cause weird DrawPattern sampling on some drivers
        this.width = FMath.max(2, MathUtil.nextPowerOfTwo(width));
        this.height = FMath.max(2, MathUtil.nextPowerOfTwo(height));
    }

    public function init (context3D :Context3D, optimizeForRenderToTexture :Bool)
    {
        assertNotDisposed();

        nativeTexture = context3D.createTexture(width, height, BGRA, optimizeForRenderToTexture);
    }

    public function createTexture (width :Int, height :Int) :Stage3DTexture
    {
        return new Stage3DTexture(this, width, height);
    }

    public function uploadBitmapData (bitmapData :BitmapData)
    {
        assertNotDisposed();

        if (width != bitmapData.width || height != bitmapData.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = new BitmapData(width, height, true, 0x00000000);
            resized.copyPixels(bitmapData, bitmapData.rect, new Point(0, 0));
            drawBorder(resized, bitmapData.width, bitmapData.height);
            nativeTexture.uploadFromBitmapData(resized);
            resized.dispose();

        } else {
            nativeTexture.uploadFromBitmapData(bitmapData);
        }
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        assertNotDisposed();

        var bitmapData = _renderer.batcher.readPixels(this, x, y, width, height);
        var pixels = Bytes.ofData(bitmapData.getPixels(new Rectangle(0, 0, width, height)));
        bitmapData.dispose();

        var ii = 0, ll = pixels.length;
        while (ii < ll) {
            // Convert from ARGB to RGBA
            var alpha = pixels.get(ii);
            pixels.set(ii, pixels.get(++ii));
            pixels.set(ii, pixels.get(++ii));
            pixels.set(ii, pixels.get(++ii));
            pixels.set(ii, alpha);
            ++ii;
        }
        return pixels;
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        assertNotDisposed();

        var sourceWPow2 = MathUtil.nextPowerOfTwo(sourceW);
        var sourceHPow2 = MathUtil.nextPowerOfTwo(sourceH);

        var copy = Bytes.alloc(4*sourceW*sourceH);
        var ii = copy.length - 1;
        while (ii >= 0) {
            // Convert from RGBA to ARGB
            var alpha = pixels.get(ii);
            copy.set(ii, pixels.get(--ii));
            copy.set(ii, pixels.get(--ii));
            copy.set(ii, pixels.get(--ii));
            copy.set(ii, alpha);
            --ii;
        }

        // Load the pixels into a BitmapData
        var bitmapData = new BitmapData(sourceWPow2, sourceHPow2, true, 0x00000000);
        bitmapData.setPixels(new Rectangle(0, 0, sourceW, sourceH), copy.getData());
        drawBorder(bitmapData, sourceW, sourceH);

        if (x == 0 && y == 0 && sourceWPow2 == width && sourceHPow2 == height) {
            // Replace the entire texture
            nativeTexture.uploadFromBitmapData(bitmapData);
        } else {
            // Since there's no way to update a texture's subregion in Stage3D, create a temporary
            // texture and draw it to this one at the right position
            var temp = _renderer.createTexture(sourceW, sourceH);
            temp.root.nativeTexture.uploadFromBitmapData(bitmapData);
            drawTexture(temp, x, y, 0, 0, sourceW, sourceH);
            temp.dispose();
        }
        bitmapData.dispose();
    }

    public function getGraphics () :Stage3DGraphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            _graphics = _renderer.createGraphics(this);
            _graphics.onResize(width, height);
        }
        return _graphics;
    }

    private function drawTexture (source :Stage3DTexture, destX :Int, destY :Int,
        sourceX :Int, sourceY :Int, sourceW :Int, sourceH :Int)
    {
        var scratch = new Vector<Float>(12, true);
        var x1 = destX;
        var y1 = destY;
        var x2 = destX + sourceW;
        var y2 = destY + sourceH;

        scratch[0] = x1;
        scratch[1] = y1;
        // scratch[2] = 0;

        scratch[3] = x2;
        scratch[4] = y1;
        // scratch[5] = 0;

        scratch[6] = x2;
        scratch[7] = y2;
        // scratch[8] = 0;

        scratch[9] = x1;
        scratch[10] = y2;
        // scratch[11] = 0;

        var ortho = new Matrix3D(Vector.ofArray([
            2/width, 0, 0, 0,
            0, -2/height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));
        ortho.transformVectors(scratch, scratch);

        var offset = _renderer.batcher.prepareDrawTexture(this, Copy, null, source);
        var data = _renderer.batcher.data;
        var u1 = (source.rootX+sourceX) / source.root.width;
        var v1 = (source.rootY+sourceY) / source.root.height;
        var u2 = u1 + sourceW/source.root.width;
        var v2 = v1 + sourceH/source.root.height;

        data[  offset] = scratch[0];
        data[++offset] = scratch[1];
        data[++offset] = u1;
        data[++offset] = v1;
        data[++offset] = 1;

        data[++offset] = scratch[3];
        data[++offset] = scratch[4];
        data[++offset] = u2;
        data[++offset] = v1;
        data[++offset] = 1;

        data[++offset] = scratch[6];
        data[++offset] = scratch[7];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = 1;

        data[++offset] = scratch[9];
        data[++offset] = scratch[10];
        data[++offset] = u1;
        data[++offset] = v2;
        data[++offset] = 1;
    }

    override private function copyFrom (that :Stage3DTextureRoot)
    {
        this.nativeTexture = that.nativeTexture;
        this.width = that.width;
        this.height = that.height;
        this._graphics = that._graphics;
    }

    override private function onDisposed ()
    {
        _renderer.batcher.deleteTexture(this);
        nativeTexture = null;
        _graphics = null;
    }

    /**
     * Extends the right and bottom edge pixels of a bitmap. This is to prevent artifacts caused by
     * sampling the outer transparency when the edge pixels are sampled.
     */
    private static function drawBorder (bitmapData :BitmapData, width :Int, height :Int)
    {
        // Right edge
        bitmapData.copyPixels(bitmapData,
            new Rectangle(width-1, 0, 1, height), new Point(width, 0));

        // Bottom edge
        bitmapData.copyPixels(bitmapData,
            new Rectangle(0, height-1, width, 1), new Point(0, height));

        // Is a one pixel border enough?
    }

    private var _renderer :Stage3DRenderer;
    private var _graphics :Stage3DGraphics;
}
