//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Font;
import flambe.math.FMath;

using flambe.util.BitSets;

/**
 * A sprite that displays a line of text using a bitmap font.
 */
class TextSprite extends Sprite
{
    public var text (getText, setText) :String;
    public var font (getFont, setFont) :Font;

    public function new (font :Font, ?text :String = "")
    {
        super();
        _font = font;
        _text = text;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
    }

    override public function draw (g :Graphics)
    {
        updateGlyphs();

        var ii = 0;
        var ll = _glyphs.length;
        while (ii < ll) {
            var glyph = _glyphs[ii];
            var offset = _offsets[ii];
            glyph.draw(g, offset, 0);
            ++ii;
        }
    }

    override public function getNaturalWidth () :Float
    {
        updateGlyphs();
        return _width;
    }

    override public function getNaturalHeight () :Float
    {
        updateGlyphs();
        return _height;
    }

    inline private function getText () :String
    {
        return _text;
    }

    private function setText (text :String) :String
    {
        _text = text;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        return text;
    }

    inline private function getFont () :Font
    {
        return _font;
    }

    private function setFont (font :Font) :Font
    {
        _font = font;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        return font;
    }

    private function updateGlyphs ()
    {
        if (_flags.contains(Sprite.TEXTSPRITE_DIRTY)) {
            _flags = _flags.remove(Sprite.TEXTSPRITE_DIRTY);

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
    }

    private var _glyphs :Array<Glyph> = null;
    private var _offsets :Array<Float> = null;
    private var _font :Font = null;
    private var _text :String = null;

    private var _width :Float = 0;
    private var _height :Float = 0;
}
