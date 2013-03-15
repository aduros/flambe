//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.util.Value;

/**
 * A fixed-size sprite that displays a single texture.
 */
class ImageSprite extends Sprite
{
    public var texture :Value<Texture>;

    public function new (texture :Value<Texture>)
    {
        super();
        this.texture = texture;
    }

    override public function draw (g :Graphics)
    {
        g.drawImage(texture._, 0, 0);
    }

    override public function getNaturalWidth () :Float
    {
        return texture._.width;
    }

    override public function getNaturalHeight () :Float
    {
        return texture._.height;
    }
}
