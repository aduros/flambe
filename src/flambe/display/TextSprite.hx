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
        var ii = 0;
        var ll = _glyphs.length;
        while (ii < ll) {
            var glyph = _glyphs[ii];
            var offset = _offsets[ii];
            glyph.draw(ctx, offset, 0);
            ++ii;
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
        _font = font;
        invalidate();
        return font;
    }

    private function invalidate ()
    {
        _glyphs = font.getGlyphs(text);
        _offsets = [0];
        _width = 0;
        _height = 0;

        var ii = 0;
        var ll = _glyphs.length;
        while (ii < ll) {
            var glyph = _glyphs[ii];
            ++ii;

            if (ii == ll) {
                // Last glyph, only advance up until its right edge
                _width += glyph.width;
            } else {
                var nextGlyph = _glyphs[ii];
                _width += glyph.xAdvance + glyph.getKerning(nextGlyph.charCode);
                _offsets.push(_width);
            }
            _height = FMath.max(_height, glyph.height + glyph.yOffset);
        }
    }

    private var _glyphs :Array<Glyph>;
    private var _offsets :Array<Float>;
    private var _font :Font;

    private var _width :Float;
    private var _height :Float;
}
