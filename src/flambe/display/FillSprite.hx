//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.Property;
import flambe.platform.DrawingContext;

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
        ctx.fillRect(color.get(), 0, 0, width.get(), height.get());
    }

    override public function getNaturalWidth () :Float
    {
        return width.get();
    }

    override public function getNaturalHeight () :Float
    {
        return height.get();
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);
        color.update(dt);
        width.update(dt);
        height.update(dt);
    }
}
