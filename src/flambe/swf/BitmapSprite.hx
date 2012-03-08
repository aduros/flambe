//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.DrawingContext;
import flambe.display.Sprite;

class BitmapSprite extends Sprite
{
    public function new (symbol :BitmapSymbol)
    {
        super();
        _symbol = symbol;
        anchorX._ = _symbol.anchorX;
        anchorY._ = _symbol.anchorY;
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawSubImage(_symbol.atlas, 0, 0, _symbol.x, _symbol.y, _symbol.width, _symbol.height);
    }

    override public function getNaturalWidth () :Float
    {
        return _symbol.width;
    }

    override public function getNaturalHeight () :Float
    {
        return _symbol.height;
    }

    private var _symbol :BitmapSymbol;
}
