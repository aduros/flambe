//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;

class PatternSprite extends Sprite
{
    public var texture :Texture;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
        this.width = new AnimatedFloat(texture.width);
        this.height = new AnimatedFloat(texture.height);
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawPattern(texture, 0, 0, width._, height._);
    }

    override public function getNaturalWidth () :Float
    {
        return width._;
    }

    override public function getNaturalHeight () :Float
    {
        return height._;
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);
        width.update(dt);
        height.update(dt);
    }
}
