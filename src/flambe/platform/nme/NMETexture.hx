//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import flash.display.BitmapData;

import flambe.display.Texture;

class NMETexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var bitmapData (default, null) :BitmapData;

#if flash11
    public var nativeTexture :flash.display3D.textures.Texture;

    // The UV texture coordinates for the bottom right corner of the image. These are less than one
    // if the texture had to be resized to a power of 2.
    public var maxU :Float;
    public var maxV :Float;
#end

    public function new (bitmapData)
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
