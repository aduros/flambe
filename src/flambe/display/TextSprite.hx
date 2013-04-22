//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.display.Font;
import flambe.math.FMath;

using flambe.util.BitSets;

/**
 * A sprite that displays a line of text using a bitmap font.
 */
class TextSprite extends Sprite
{
    public var text (get_text, set_text) :String;
    public var font (get_font, set_font) :Font;

    public var wrapWidth (default, null) :AnimatedFloat;
    public var align :TextAlign;

    public function new (font :Font, ?text :String = "")
    {
        super();
        _font = font;
        _text = text;
        align = Left;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);

        wrapWidth = new AnimatedFloat(0, function (_,_) {
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        });
    }

    override public function draw (g :Graphics)
    {
        updateLayout();
        _layout.draw(g, align);
    }

    override public function getNaturalWidth () :Float
    {
        updateLayout();
        return _layout.width;
    }

    override public function getNaturalHeight () :Float
    {
        updateLayout();
        return _layout.height;
    }

    inline private function get_text () :String
    {
        return _text;
    }

    private function set_text (text :String) :String
    {
        _text = text;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        return text;
    }

    inline private function get_font () :Font
    {
        return _font;
    }

    private function set_font (font :Font) :Font
    {
        _font = font;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        return font;
    }

    private function updateLayout ()
    {
        if (_flags.contains(Sprite.TEXTSPRITE_DIRTY)) {
            _flags = _flags.remove(Sprite.TEXTSPRITE_DIRTY);
            _layout = font.layoutText(_text, wrapWidth._);
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);
        wrapWidth.update(dt);
    }

    private var _font :Font;
    private var _text :String;

    private var _layout :TextLayout = null;
}
