//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.util.Value;

class FillSprite extends Sprite
{
    public var color (default, null) :Value<Int>;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public function new (color :Int, width :Float, height :Float)
    {
        super();
        this.color = new Value<Int>(color);
        this.width = new AnimatedFloat(width);
        this.height = new AnimatedFloat(height);
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.fillRect(color._, 0, 0, width._, height._);
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
