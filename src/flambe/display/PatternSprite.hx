//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;

/**
 * A resizable sprite that tiles a texture over its area.
 */
class PatternSprite extends Sprite
{
    public var texture :Texture;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public function new (texture :Texture, ?width :Float = -1, ?height :Float = -1)
    {
        super();
        this.texture = texture;

        if (width < 0) {
            width = texture.width;
        }
        this.width = new AnimatedFloat(width);

        if (height < 0) {
            height = texture.height;
        }
        this.height = new AnimatedFloat(height);
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

    /**
     * Convenience method to set the width and height.
     * @returns This instance, for chaining.
     */
    public function setSize (width :Float, height :Float) :PatternSprite
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
