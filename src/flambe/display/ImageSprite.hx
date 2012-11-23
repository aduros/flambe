//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * A fixed-size sprite that displays a single texture.
 */
class ImageSprite extends Sprite
{
    public var texture :Texture;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
    }

    override public function draw (g :Graphics)
    {
        g.drawImage(texture, 0, 0);
    }

    override public function getNaturalWidth () :Float
    {
        return texture.width;
    }

    override public function getNaturalHeight () :Float
    {
        return texture.height;
    }
}
