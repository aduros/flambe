//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Font;
import flambe.math.FMath;

/**
 * A sprite that displays a line of text using a bitmap font.
 */
class TextSprite extends Sprite
{
    public var text (default, setText) :String;
    public var font (getFont, setFont) :Font;

    public function new (font :Font, ?text :String = "")
    {
        super();
        _font = font;
        setText(text);
    }

    override public function draw (ctx :DrawingContext)
    {
        var x = 0;
        for (glyph in _glyphs) {
            glyph.draw(ctx, x, 0);
            x += glyph.xAdvance;
        }
    }

    override public function getNaturalWidth () :Float
    {
        return _width;
    }

    override public function getNaturalHeight () :Float
    {
        return _height;
    }

    private function setText (text :String) :String
    {
        this.text = text;
        invalidate();
        return text;
    }

    inline private function getFont () :Font
    {
        return _font;
    }

    private function setFont (font :Font) :Font
    {
        this.font = font;
        invalidate();
        return font;
    }

    private function invalidate ()
    {
        _glyphs = font.getGlyphs(text);

        _width = 0;
        _height = 0;
        for (glyph in _glyphs) {
            _width += glyph.xAdvance;
            _height = FMath.max(_height, glyph.height + glyph.yOffset);
        }
    }

    private var _glyphs :Array<Glyph>;
    private var _font :Font;

    private var _width :Float;
    private var _height :Float;
}
