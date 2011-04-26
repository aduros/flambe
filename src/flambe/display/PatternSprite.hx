package flambe.display;

import flambe.animation.Property;
import flambe.platform.DrawingContext;

class PatternSprite extends Sprite
{
    public var texture :Texture;
    public var width (default, null) :PFloat;
    public var height (default, null) :PFloat;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
        this.width = new PFloat(texture.width);
        this.height = new PFloat(texture.height);
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawPattern(texture, 0, 0, width.get(), height.get());
    }

    override public function getNaturalWidth () :Float
    {
        return width.get();
    }

    override public function getNaturalHeight () :Float
    {
        return height.get();
    }

    override public function update (dt :Int)
    {
        super.update(dt);
        width.update(dt);
        height.update(dt);
    }
}
