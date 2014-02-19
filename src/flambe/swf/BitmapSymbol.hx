//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.ImageSprite;
import flambe.display.SubTexture;
import flambe.display.Texture;
import flambe.swf.Format;

/**
 * Defines a Flump atlased texture.
 */
class BitmapSymbol
    implements Symbol
{
    public var name (get, null) :String;
    public var texture (default, null) :SubTexture;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (json :TextureFormat, atlas :Texture)
    {
        _name = json.symbol;

        var rect = json.rect;
        texture = atlas.subTexture(rect[0], rect[1], rect[2], rect[3]);

        var origin = json.origin;
        if (origin != null) {
            anchorX = origin[0];
            anchorY = origin[1];
        } else {
            anchorX = 0;
            anchorY = 0;
        }
    }

    public function createSprite () :ImageSprite
    {
        var sprite = new ImageSprite(texture);
        sprite.setAnchor(anchorX, anchorY);
        return sprite;
    }

    inline private function get_name () :String
    {
        return _name;
    }

    private var _name :String;
}

