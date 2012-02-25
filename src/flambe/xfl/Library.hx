//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.xfl;

import haxe.xml.Fast;

import flambe.asset.AssetPack;
import flambe.display.Sprite;

using flambe.util.Xmls;

class Library
{
    public var name (default, null) :String;

    public function new (pack :AssetPack, baseDir :String)
    {
        _symbols = new Hash();

        var xml = Xml.parse(pack.loadFile(baseDir + "/resources.xml")).firstChild();
        var reader = new Fast(xml);

        var movies = [];
        for (movieElement in reader.nodes.movie) {
            var movie = new MovieSymbol(movieElement);
            movies.push(movie);
            _symbols.set(movie.name, movie);
        }

        for (atlasElement in reader.nodes.atlas) {
            // TODO(bruno): Should textures be relative to baseDir?
            var atlas = pack.loadTexture(atlasElement.att.filename);
            for (textureElement in atlasElement.nodes.texture) {
                var bitmap = new BitmapSymbol(textureElement, atlas);
                _symbols.set(bitmap.name, bitmap);
            }
        }

        // Now that all symbols have been parsed, go through keyframes and resolve references
        for (movie in movies) {
            for (layer in movie.layers) {
                for (kf in layer.keyframes) {
                    var symbol = _symbols.get(kf.symbolName);
                    if (symbol != null) {
                        if (layer.lastSymbol == null) {
                            layer.lastSymbol = symbol;
                        } else if (layer.lastSymbol != symbol) {
                            layer.multipleSymbols = true;
                        }
                        kf.symbol = symbol;
                    }
                }
            }
        }
    }

    inline public function movie (symbolName :String) :MovieSprite
    {
        return cast sprite(symbolName);
    }

    inline public function symbol (symbolName :String) :Symbol
    {
        return _symbols.get(symbolName);
    }

    public function sprite (symbolName :String) :Sprite
    {
        var symbol = _symbols.get(symbolName);
        return (symbol != null) ? symbol.createSprite() : null;
    }

    inline public function iterator () :Iterator<Symbol>
    {
        return _symbols.iterator();
    }

    private var _symbols :Hash<Symbol>;
}
