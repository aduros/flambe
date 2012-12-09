//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.swf.Format;

/**
 * Defines a Flump atlased texture.
 */
class BitmapSymbol
    implements Symbol
{
    public var name (get_name, null) :String;
    public var atlas (default, null) :Texture;
    public var x (default, null) :Int;
    public var y (default, null) :Int;
    public var width (default, null) :Int;
    public var height (default, null) :Int;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (reader :TextureFormat, atlas :Texture)
    {
        _name = reader.symbol;
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
        } else {
            anchorX = 0;
            anchorY = 0;
        }
    }

    public function createSprite () :Sprite
    {
        return new BitmapSprite(this);
    }

    public function get_name () :String
    {
        return _name;
    }

    private var _name :String;
}

