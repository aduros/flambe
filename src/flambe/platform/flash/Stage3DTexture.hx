//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.geom.Point;

import flambe.display.Texture;

class Stage3DTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var nativeTexture (default, null) :flash.display3D.textures.Texture;

    // The UV texture coordinates for the bottom right corner of the image. These are less than one
    // if the texture had to be resized to a power of 2.
    public var maxU (default, null) :Float;
    public var maxV (default, null) :Float;

    public function new (width :Int, height :Int)
    {
        _width = nextPowerOfTwo(width);
        _height = nextPowerOfTwo(height);

        maxU = width / _width;
        maxV = height / _height;
    }

    public function init (context3D :Context3D, optimizeForRenderToTexture :Bool)
    {
        nativeTexture = context3D.createTexture(_width, _height, BGRA, optimizeForRenderToTexture);
    }

    public function uploadBitmapData (bitmapData :BitmapData)
    {
        if (_width != bitmapData.width || _height != bitmapData.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = new BitmapData(_width, _height, true, 0x00000000);
            resized.copyPixels(bitmapData, bitmapData.rect, new Point(0, 0));
            bitmapData = resized;
        }
        nativeTexture.uploadFromBitmapData(bitmapData);
    }

    inline private function getWidth () :Int
    {
        return _width;
    }

    inline private function getHeight () :Int
    {
        return _height;
    }

    private static function nextPowerOfTwo (n :Int)
    {
        var p = 1;
        while (p < n) {
            p <<= 1;
        }
        return p;
    }

    private var _width :Int;
    private var _height :Int;
}
