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
    public var text (get, set) :String;

    /** The font used to display the text. */
    public var font (get, set) :Font;

    /**
     * The maximum available width of this text before word wrapping to a new line. Defaults to 0
     * (no word wrapping).
     */
    public var wrapWidth (default, null) :AnimatedFloat;

    /**
     * The horizontal text alignment, for multiline text. Left by default.
     */
    public var align (get, set) :TextAlign;

    public function new (font :Font, ?text :String = "")
    {
        super();
        _font = font;
        _text = text;
        _align = Left;
        _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);

        wrapWidth = new AnimatedFloat(0, function (_,_) {
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        });
    }

    override public function draw (g :Graphics)
    {
        updateLayout();

#if flambe_debug_text
        // Draw the bounding boxes for debugging
        g.fillRect(0xff0000, 0, 0, getNaturalWidth(), getNaturalHeight());
        g.fillRect(0x00ff00, _layout.bounds.x, _layout.bounds.y, _layout.bounds.width, _layout.bounds.height);
#end

        _layout.draw(g, align);
    }

    override public function getNaturalWidth () :Float
    {
        updateLayout();
        return (wrapWidth._ > 0) ? wrapWidth._ : _layout.bounds.width;
    }

    override public function getNaturalHeight () :Float
    {
        updateLayout();
        var paddedHeight = _layout.lines * _font.lineHeight;
        var boundsHeight = _layout.bounds.height;
        return FMath.max(paddedHeight, boundsHeight);
    }

    override public function containsLocal (localX :Float, localY :Float) :Bool
    {
        updateLayout();
        return _layout.bounds.contains(localX, localY);
    }

    inline private function get_text () :String
    {
        return _text;
    }

    private function set_text (text :String) :String
    {
        if (text != _text) {
            _text = text;
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        }
        return text;
    }

    inline private function get_font () :Font
    {
        return _font;
    }

    private function set_font (font :Font) :Font
    {
        if (font != _font) {
            _font = font;
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        }
        return font;
    }

    inline private function get_align () :TextAlign
    {
        return _align;
    }

    private function set_align (align :TextAlign) :TextAlign
    {
        if (align != _align) {
            _align = align;
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        }
        return align;
    }

    private function updateLayout ()
    {
#if debug
        var reloadCount = _font.checkReload();
        if (reloadCount != _lastReloadCount) {
            _lastReloadCount = reloadCount;
            _flags = _flags.add(Sprite.TEXTSPRITE_DIRTY);
        }
#end

        // Recreate the layout if necessary
        if (_flags.contains(Sprite.TEXTSPRITE_DIRTY)) {
            _flags = _flags.remove(Sprite.TEXTSPRITE_DIRTY);
            _layout = font.layoutText(_text, _align, wrapWidth._);
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);
        wrapWidth.update(dt);
    }

    private var _font :Font;
    private var _text :String;
    private var _align :TextAlign;

    private var _layout :TextLayout = null;

#if debug
    private var _lastReloadCount :Int = -1;
#end
}
