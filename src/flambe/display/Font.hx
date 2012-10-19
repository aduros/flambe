//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.asset.AssetPack;

using StringTools;

/**
 * A bitmap font, created in any tool that exports the BMFont format, such as the original BMFont
 * editor, Hiero, or Glyph Designer.
 */
class Font
{
    /**
     * The name that was used to load this font.
     */
    public var name (default, null) :String;

    /**
     * The vertical size of this font, in pixels.
     */
    public var size (default, null) :Float;

    /**
     * Parses a font using files in an asset pack.
     * @param name The path to the font within the asset pack, excluding the .fnt suffix.
     */
    public function new (pack :AssetPack, name :String)
    {
        this.name = name;
        _glyphs = new IntHash();

        var parser = new ConfigParser(pack.loadFile(name + ".fnt"));
        var pages = new IntHash<Texture>();

        // The basename of the font's path, where we'll find the textures
        var idx = name.lastIndexOf("/");
        var basePath = (idx >= 0) ? name.substr(0, idx+1) : "";

        for (keyword in parser.keywords()) {
            switch (keyword) {
            case "info":
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "size":
                        size = pair.getInt();
                    }
                }

            case "page":
                var pageId :Int = 0;
                var file :String = null;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                        case "id":
                            pageId = pair.getInt();
                        case "file":
                            file = pair.getString();
                    }
                }
                pages.set(pageId, pack.loadTexture(basePath + file));

            case "char":
                var glyph = null;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "id":
                        glyph = new Glyph(pair.getInt());
                    case "x":
                        glyph.x = pair.getInt();
                    case "y":
                        glyph.y = pair.getInt();
                    case "width":
                        glyph.width = pair.getInt();
                    case "height":
                        glyph.height = pair.getInt();
                    case "page":
                        glyph.page = pages.get(pair.getInt());
                    case "xoffset":
                        glyph.xOffset = pair.getInt();
                    case "yoffset":
                        glyph.yOffset = pair.getInt();
                    case "xadvance":
                        glyph.xAdvance = pair.getInt();
                    }
                }
                _glyphs.set(glyph.charCode, glyph);

            case "kerning":
                var first :Glyph = null;
                var second = -1;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "first":
                        first = _glyphs.get(pair.getInt());
                    case "second":
                        second = pair.getInt();
                    case "amount":
                        first._internal_setKerning(second, pair.getInt());
                    }
                }
            }
        }
    }

    /**
     * Splits text into multiple lines that fit into a given width when displayed using this font.
     */
    public function splitLines (text :String, maxWidth :Float) :Array<String>
    {
        var glyphs = getGlyphs(text);
        var line = "";
        var lines = [];
        var x = 0;
        var ii = 0;
        var ll = glyphs.length;
        var lastSpaceIdx = -1;

        while (ii < ll) {
            var glyph = glyphs[ii];
            if (x + glyph.width > maxWidth) {
                // Ran off the edge, add a line
                x = 0;
                var space = line.lastIndexOf(" ");
                if (space >= 0) {
                    // Backtrack to the beginning of the last word
                    lines.push(line.substr(0, space));
                    ii = lastSpaceIdx + 1;
                } else {
                    lines.push(line);
                }
                line = "";

            } else {
                if (glyph.charCode == " ".code) {
                    lastSpaceIdx = ii;
                }
                line += String.fromCharCode(glyph.charCode);
                x += glyph.xAdvance;
                ++ii;
                if (ii != ll) {
                    var nextGlyph = glyphs[ii];
                    x += glyph.getKerning(nextGlyph.charCode);
                }
            }
        }
        lines.push(line);

        return lines;
    }

    /**
     * Get the list of Glyphs that make up a string. Characters without glyphs in this font will be
     * missing from the list.
     */
    public function getGlyphs (text :String) :Array<Glyph>
    {
        var list = [];
        for (ii in 0...text.length) {
            var charCode = text.fastCodeAt(ii);
            var glyph = _glyphs.get(charCode);
            if (glyph != null) {
                list.push(glyph);
            } else {
                Log.warn("Requested a missing character from font",
                    ["font", name, "charCode", charCode]);
            }
        }
        return list;
    }

    /**
     * Get the Glyph for a given character code.
     */
    inline public function getGlyph (charCode :Int) :Glyph
    {
        return _glyphs.get(charCode);
    }

    private var _glyphs :IntHash<Glyph>;
}

/**
 * Represents a single glyph in a bitmap font.
 */
class Glyph
{
    /**
     * This glyph's ASCII character code.
     */
    public var charCode (default, null) :Int;

    // Location and dimensions of this glyph on the sprite sheet
    public var x :Int;
    public var y :Int;
    public var width :Int;
    public var height :Int;

    /**
     * The atlas that contains this glyph.
     */
    public var page :Texture;

    public var xOffset :Int;
    public var yOffset :Int;

    public var xAdvance :Int;

    /** @private */ public function new (charCode :Int)
    {
        this.charCode = charCode;
    }

    /**
     * Draws this glyph to a DrawingContext surface.
     */
    public function draw (ctx :DrawingContext, destX :Float, destY :Float)
    {
        // Avoid drawing whitespace
        if (width > 0) {
            ctx.drawSubImage(page, destX + xOffset, destY + yOffset, x, y, width, height);
        }
    }

    public function getKerning (nextCharCode :Int) :Int
    {
        return (_kernings != null) ? Std.int(_kernings.get(nextCharCode)) : 0;
    }

    /** @private */ public function _internal_setKerning (nextCharCode :Int, amount :Int)
    {
        if (_kernings == null) {
            _kernings = new IntHash();
        }
        _kernings.set(nextCharCode, amount);
    }

    private var _kernings :IntHash<Int>;
}

private class ConfigParser
{
    public function new (config :String)
    {
        _configText = config;
        _keywordPattern = ~/([a-z]+)(.*)/;
        _pairPattern = ~/([a-z]+)=("[^"]*"|[^\s]+)/;
    }

    public function keywords () :Iterator<String>
    {
        var text = _configText;
        return {
            next: function () {
                text = advance(text, _keywordPattern);
                _pairText = _keywordPattern.matched(2);
                return _keywordPattern.matched(1);
            },
            hasNext: function () {
                return _keywordPattern.match(text);
            }
        };
    }

    public function pairs () :Iterator<ConfigPair>
    {
        var text = _pairText;
        return {
            next: function () {
                text = advance(text, _pairPattern);
                return new ConfigPair(_pairPattern.matched(1), _pairPattern.matched(2));
            },
            hasNext: function () {
                return _pairPattern.match(text);
            }
        };
    }

    private static function advance (text :String, expr :EReg)
    {
        var m = expr.matchedPos();
        return text.substr(m.pos + m.len, text.length);
    }

    // The entire config file contents
    private var _configText :String;

    // The line currently being processed
    private var _pairText :String;

    private var _keywordPattern :EReg;
    private var _pairPattern :EReg;
}

private class ConfigPair
{
    public var key (default, null) :String;

    public function new (key :String, value :String)
    {
        this.key = key;
        _value = value;
    }

    public function getInt () :Int
    {
        return Std.parseInt(_value);
    }

    public function getString () :String
    {
        if (_value.fastCodeAt(0) != "\"".code) {
            return null;
        }
        return _value.substr(1, _value.length-2);
    }

    private var _value :String;
}
