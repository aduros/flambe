//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.BitmapData;

import flambe.display.Texture;

class Stage3DTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    // TODO(bruno): Don't keep the BitmapData around in RAM
    public var bitmapData (default, null) :BitmapData;

    public var nativeTexture :flash.display3D.textures.Texture;

    // The UV texture coordinates for the bottom right corner of the image. These are less than one
    // if the texture had to be resized to a power of 2.
    public var maxU :Float;
    public var maxV :Float;

    public function new (bitmapData :BitmapData)
    {
        this.bitmapData = bitmapData;
    }

    inline private function getWidth () :Int
    {
        return bitmapData.width;
    }

    inline private function getHeight () :Int
    {
        return bitmapData.height;
    }
}
