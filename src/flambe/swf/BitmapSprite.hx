//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Graphics;
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
        anchorX._ = symbol.anchorX;
        anchorY._ = symbol.anchorY;
    }

    override public function draw (g :Graphics)
    {
        g.drawSubImage(symbol.atlas, 0, 0, symbol.x, symbol.y, symbol.width, symbol.height);
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
