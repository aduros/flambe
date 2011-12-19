//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.Property;

class FillSprite extends Sprite
{
    public var color (default, null) :PColor;
    public var width (default, null) :PFloat;
    public var height (default, null) :PFloat;

    public function new (color :Int, width :Float, height :Float)
    {
        super();
        this.color = new PInt(color);
        this.width = new PFloat(width);
        this.height = new PFloat(height);
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.fillRect(color._, -anchorX._, -anchorY._, width._, height._);
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
        color.update(dt);
        width.update(dt);
        height.update(dt);
    }
}
