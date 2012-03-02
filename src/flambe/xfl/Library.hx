//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.xfl;

import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.xfl.Format;

class Library
{
    public var name (default, null) :String;

    public function new (pack :AssetPack, baseDir :String)
    {
        _symbols = new Hash();

        var reader :Format = Json.parse(pack.loadFile(baseDir + "/resources.json"));

        var movies = [];
        for (movieObject in reader.movies) {
            var movie = new MovieSymbol(movieObject);
            movies.push(movie);
            _symbols.set(movie.name, movie);
        }

        for (atlasObject in reader.atlases) {
            // TODO(bruno): Should textures be relative to baseDir?
            var atlas = pack.loadTexture(atlasObject.file);
            for (textureObject in atlasObject.textures) {
                var bitmap = new BitmapSymbol(textureObject, atlas);
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

// TODO(bruno): Temporary hack for native JSON parsing until it becomes available in the next
// version of haxe
#if (flash_10_3 || js)
@:native("JSON") extern private class Json {
    public static function parse (text :String) :Dynamic;
}
#else
typedef Json = hxjson2.JSON;
#end
