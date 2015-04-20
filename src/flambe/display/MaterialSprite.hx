//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * A sprite that displays based on a material.
 */
class MaterialSprite extends Sprite
{
    /**
     * The texture being displayed, or null if none.
     */
    public var texture :Texture;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
    }

    /** Owner entity must have a material component */
    override public function onAdded()
    {
        super.onAdded();

        if(owner.has(Material))
        {
            _material = owner.get(Material);
            _material.texture = this.texture;
        }
        else
            this.dispose();
    }

    override public function draw (g :Graphics)
    {
        if (_material != null) {
            g.drawMaterial(_material, 0, 0);
        }
    }

    override public function getNaturalWidth () :Float
    {
        return (texture != null) ? texture.width : 0;
    }

    override public function getNaturalHeight () :Float
    {
        return (texture != null) ? texture.height : 0;
    }

    private var _material :Material = null;
}
