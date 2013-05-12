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

import flambe.display.Graphics;
import flambe.display.Texture;

class Stage3DTexture
    implements Texture
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var graphics (get, null) :Graphics;

    public var nativeTexture (default, null) :flash.display3D.textures.Texture;

    // The UV texture coordinates for the bottom right corner of the image. These are less than one
    // if the texture had to be resized to a power of 2.
    public var maxU (default, null) :Float;
    public var maxV (default, null) :Float;

    public function new (renderer :Stage3DRenderer, width :Int, height :Int)
    {
        _renderer = renderer;
        _width = width;
        _height = height;

        _widthPow2 = nextPowerOfTwo(width);
        _heightPow2 = nextPowerOfTwo(height);

        maxU = width / _widthPow2;
        maxV = height / _heightPow2;
    }

    public function init (context3D :Context3D, optimizeForRenderToTexture :Bool)
    {
        nativeTexture = context3D.createTexture(_widthPow2, _heightPow2,
            BGRA, optimizeForRenderToTexture);
    }

    public function uploadBitmapData (bitmapData :BitmapData)
    {
        if (_widthPow2 != bitmapData.width || _heightPow2 != bitmapData.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = new BitmapData(_widthPow2, _heightPow2, true, 0x00000000);
            resized.copyPixels(bitmapData, bitmapData.rect, new Point(0, 0));
            drawBorder(resized, bitmapData.width, bitmapData.height);
            bitmapData = resized;
        }
        nativeTexture.uploadFromBitmapData(bitmapData);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        var bitmapData = _renderer.batcher.readPixels(this, x, y, width, height);
        var pixels = Bytes.ofData(bitmapData.getPixels(new Rectangle(0, 0, width, height)));
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
        var sourceWPow2 = nextPowerOfTwo(sourceW);
        var sourceHPow2 = nextPowerOfTwo(sourceH);

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

        if (x == 0 && y == 0 && sourceWPow2 == _widthPow2 && sourceHPow2 == _heightPow2) {
            // Replace the entire texture
            nativeTexture.uploadFromBitmapData(bitmapData);
        } else {
            // Since there's no way to update a texture's subregion in Stage3D, create a temporary
            // texture and draw it to this one at the right position
            var temp = _renderer.createEmptyTexture(sourceW, sourceH);
            temp.nativeTexture.uploadFromBitmapData(bitmapData);
            drawTexture(temp, x, y, 0, 0, sourceW, sourceH);
        }
    }

    public function getColorBounds(mask :Int, color :Int, ?negate = false) :flambe.math.Rectangle
    {
        var bitmapData = _renderer.batcher.readPixels(this, 0, 0, width, height);
        var bounds = bitmapData.getColorBoundsRect(mask, color, !negate);
        return new flambe.math.Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    inline private function get_width () :Int
    {
        return _width;
    }

    inline private function get_height () :Int
    {
        return _height;
    }

    private function get_graphics () :Stage3DGraphics
    {
        if (_graphics == null) {
            _graphics = _renderer.createGraphics(this);
            _graphics.reset(_widthPow2, _heightPow2);
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
            2/_widthPow2, 0, 0, 0,
            0, -2/_heightPow2, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));
        ortho.transformVectors(scratch, scratch);

        var offset = _renderer.batcher.prepareDrawImage(this, CopyExperimental, null, source);
        var data = _renderer.batcher.data;
        var u1 = source.maxU * sourceX/source.width;
        var v1 = source.maxV * sourceY/source.height;
        var u2 = source.maxU * (sourceX+sourceW)/source.width;
        var v2 = source.maxV * (sourceY+sourceH)/source.height;

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

    private static function nextPowerOfTwo (n :Int) :Int
    {
        var p = 1;
        while (p < n) {
            p <<= 1;
        }
        return p;
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

    private var _width :Int;
    private var _height :Int;

    private var _widthPow2 :Int;
    private var _heightPow2 :Int;

    private var _renderer :Stage3DRenderer;
    private var _graphics :Stage3DGraphics;
}
