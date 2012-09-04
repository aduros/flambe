//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.DrawingContext;
import flambe.display.Sprite;

/**
 * An instanced Flump atlased texture.
 */
class BitmapSprite extends Sprite
{
    /**
     * The symbol this sprite displays.
     */
    public var symbol (default, null) :BitmapSymbol;

    public function new (symbol :BitmapSymbol)
    {
        super();
        this.symbol = symbol;
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawSubImage(symbol.atlas, -symbol.anchorX, -symbol.anchorY,
            symbol.x, symbol.y, symbol.width, symbol.height);
    }

    override public function containsLocal (localX :Float, localY :Float)
    {
        // We can't set the _anchorX/Y properties, since they're modified by LayerAnimator, so
        // instead they have to be handled specially when drawing and hit testing
        return super.containsLocal(localX+symbol.anchorX, localY+symbol.anchorY);
    }

    override public function getNaturalWidth () :Float
    {
        return symbol.width;
    }

    override public function getNaturalHeight () :Float
    {
        return symbol.height;
    }
}
