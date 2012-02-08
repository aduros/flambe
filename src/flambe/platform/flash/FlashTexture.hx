//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.BitmapData;

import flambe.display.Texture;

class FlashTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var bitmapData (default, null) :BitmapData;

#if flash11
    public var nativeTexture :flash.display3D.textures.Texture;
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
