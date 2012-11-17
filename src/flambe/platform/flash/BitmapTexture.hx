//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.BitmapData;

import flambe.display.Texture;

class BitmapTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var bitmapData (default, null) :BitmapData;

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
