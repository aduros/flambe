//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.util.Value;

/**
 * A sprite that displays a rectangle filled with a given color.
 */
class FillSprite extends Sprite
{
    public var color :Int;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public function new (color :Int, width :Float, height :Float)
    {
        super();
        this.color = color;
        this.width = new AnimatedFloat(width);
        this.height = new AnimatedFloat(height);
    }

    override public function draw (g :Graphics)
    {
        g.fillRect(color, 0, 0, width._, height._);
    }

    override public function getNaturalWidth () :Float
    {
        return width._;
    }

    override public function getNaturalHeight () :Float
    {
        return height._;
    }

    /**
     * Chainable convenience method to set the width and height.
     * @returns This instance, for chaining.
     */
    public function setSize (width :Float, height :Float) :FillSprite
    {
        this.width._ = width;
        this.height._ = height;
        return this;
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);
        width.update(dt);
        height.update(dt);
    }
}
