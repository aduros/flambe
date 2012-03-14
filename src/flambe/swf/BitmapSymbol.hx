//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.swf.Format;

class BitmapSymbol
    implements Symbol
{
    public var name (getName, null) :String;
    public var atlas (default, null) :Texture;
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var width (default, null) :Float;
    public var height (default, null) :Float;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (reader :TextureFormat, atlas :Texture)
    {
        _name = reader.name;
        this.atlas = atlas;

        var rect = reader.rect;
        x = rect[0];
        y = rect[1];
        width = rect[2];
        height = rect[3];

        var offset = reader.offset;
        if (offset != null) {
            anchorX = -offset[0];
            anchorY = -offset[1];
        }
    }

    public function createSprite () :Sprite
    {
        return new BitmapSprite(this);
    }

    public function getName () :String
    {
        return _name;
    }

    private var _name :String;
}

