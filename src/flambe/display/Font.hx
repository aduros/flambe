//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.display;

import flambe.asset.AssetPack;
import flambe.platform.DrawingContext;

using StringTools;

class Font
{
    public var name (default, null) :String;

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
            }
        }
    }

    // Get the list of Glyphs that make up a string
    public function getGlyphs (text :String) :Array<Glyph>
    {
        var list = [];
        for (ii in 0...text.length) {
            var charCode = text.fastCodeAt(ii);
            list.push(_glyphs.get(charCode));
        }
        return list;
    }

    public function getGlyph (charCode :Int)
    {
        return _glyphs.get(charCode);
    }

    private var _glyphs :IntHash<Glyph>;
}

// TODO: Kerning
class Glyph
{
    // This glyph's ASCII character code
    public var charCode (default, null) :Int;

    // Location and dimensions of this glyph on the sprite sheet
    public var x :Int;
    public var y :Int;
    public var width :Int;
    public var height :Int;

    // The sprite sheet that contains this glyph
    public var page :Texture;

    public var xOffset :Int;
    public var yOffset :Int;

    public var xAdvance :Int;

    public function new (charCode :Int)
    {
        this.charCode = charCode;
    }

    public function draw (ctx :DrawingContext, destX :Float, destY :Float)
    {
        ctx.drawSubImage(page, destX + xOffset, destY + yOffset, x, y, width, height);
    }
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
        var self = this;
        var text = _configText;
        return {
            next: function () {
                text = advance(text, self._keywordPattern);
                self._pairText = self._keywordPattern.matched(2);
                return self._keywordPattern.matched(1);
            },
            hasNext: function () {
                return self._keywordPattern.match(text);
            }
        };
    }

    public function pairs () :Iterator<ConfigPair>
    {
        var self = this;
        var text = _pairText;
        return {
            next: function () {
                text = advance(text, self._pairPattern);
                return new ConfigPair(self._pairPattern.matched(1), self._pairPattern.matched(2));
            },
            hasNext: function () {
                return self._pairPattern.match(text);
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
        if (_value.fastCodeAt(0) != 34) {
            return null;
        }
        return _value.substr(1, _value.length-2);
    }

    private var _value :String;
}
