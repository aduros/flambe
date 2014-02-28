//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import haxe.Json;

import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.swf.Format;
import flambe.util.Assert;

using flambe.util.Strings;

/**
 * An exported Flump library containing movies and bitmaps.
 */
class Library
{
    /**
     * The original frame rate of movies in this library.
     */
    public var frameRate (default, null) :Float;

    /**
     * Creates a library using files in an AssetPack.
     * @param baseDir The directory in the pack containing Flump's library.json and texture atlases.
     */
    public function new (pack :AssetPack, baseDir :String)
    {
        _symbols = new Map();

        var json :Format = Json.parse(pack.getFile(baseDir + "/library.json").toString());

        frameRate = json.frameRate;

        var movies = [];
        for (movieObject in json.movies) {
            var movie = new MovieSymbol(this, movieObject);
            movies.push(movie);
            _symbols.set(movie.name, movie);
        }

        var groups = json.textureGroups;
        if (groups[0].scaleFactor != 1 || groups.length > 1) {
            Log.warn("Flambe doesn't support Flump's Additional Scale Factors. " +
                "Use Base Scales and load from different asset packs instead.");
        }
        var atlases = groups[0].atlases;
        for (atlasObject in atlases) {
            var atlas = pack.getTexture(baseDir + "/" + atlasObject.file.removeFileExtension());
            for (textureObject in atlasObject.textures) {
                var bitmap = new BitmapSymbol(textureObject, atlas);
                _symbols.set(bitmap.name, bitmap);
            }
        }

        // Now that all symbols have been parsed, go through keyframes and resolve references
        for (movie in movies) {
            for (layer in movie.layers) {
                var keyframes = layer.keyframes;
                var ll = keyframes.length;
                for (ii in 0...ll) {
                    var kf = keyframes[ii];
                    if (kf.symbolName != null) {
                        var symbol = _symbols.get(kf.symbolName);
                        Assert.that(symbol != null);
                        kf.setSymbol(symbol);
                    }

                    // Specially handle "stop frames". These are one-frame keyframes that preceed an
                    // invisible or empty keyframe. They don't appear in Flash (or Starling Flump)
                    // since movies use the authored FLA framerate there (typically 30 FPS). Flambe
                    // animates at 60 FPS, which can cause unexpected motion/flickering as those
                    // one-frame keyframes are interpolated. So, assume that these frames are never
                    // meant to actually be displayed and hide them.
                    if (kf.tweened && kf.duration == 1 && ii+1 < ll) {
                        var nextKf = keyframes[ii+1];
                        if (!nextKf.visible || nextKf.symbolName == null) {
                            kf.setVisible(false);
                        }
                    }
                }
            }
        }
    }

    /**
     * Creates a library procedurally using a set of Flipbook definitions. Each flipbook will be
     * converted to a movie that can be instanciated with `createMovie()`.
     *
     * Example:
     * ```haxe
     * var lib = Library.fromFlipbooks({
     *     // A walk animation from a 5x3 sprite sheet, that lasts 5 seconds
     *     "walk": new Flipbook(spriteSheet.split(5, 3)).setDuration(5).setAnchor(10, 10),
     *
     *     // Another animation where each frame comes from a separate image (Jump1.png, Jump2.png, ...)
     *     "jump": new Flipbook([for (frame in 1...10) pack.getTexture("Jump"+frame)]),
     * });
     *
     * var movie = lib.createMovie("walk");
     * ```
     */
    public static function fromFlipbooks (flipbooks :Dynamic<Flipbook>) :Library
    {
        var lib = Type.createEmptyInstance(Library);
        lib._symbols = new Map();
        lib.frameRate = 60;

        for (name in Reflect.fields(flipbooks)) {
            var flipbook :Flipbook = Reflect.field(flipbooks, name);

            // Fake up some Flump metadata to create a movie symbol
            var keyframes :Array<KeyframeFormat> = [];
            for (frame in flipbook.frames) {
                keyframes.push(cast {
                    duration: frame.duration*lib.frameRate,
                    label: frame.label,
                    pivot: [frame.anchorX, frame.anchorY],
                    ref: "", // Hack so that this keyframe doesn't get marked as empty
                });
            }
            var movie = new MovieSymbol(lib, {
                id: name,
                layers: [{
                    name: "flipbook",
                    flipbook: true,
                    keyframes: keyframes,
                }],
            });
            lib._symbols.set(name, movie);

            // Assign symbols at each keyframe
            var keyframes = movie.layers[0].keyframes;
            for (ii in 0...flipbook.frames.length) {
                keyframes[ii].setSymbol(flipbook.frames[ii].toSymbol());
            }
        }

        return lib;
    }

    /**
     * Retrieve a name symbol from this library, or null if not found.
     */
    inline public function getSymbol (symbolName :String) :Symbol
    {
        return _symbols.get(symbolName);
    }

    /**
     * Creates a sprite from a symbol name, it'll either be a movie or a bitmap.
     * @param required If true and the symbol is not in this library, an error is thrown.
     */
    public function createSprite (symbolName :String, required :Bool = true) :Sprite
    {
        var symbol = _symbols.get(symbolName);
        if (symbol == null) {
            if (required) {
                throw "Missing symbol".withFields(["name", symbolName]);
            }
            return null;
        }
        return symbol.createSprite();
    }

    /**
     * Creates a movie sprite from a symbol name.
     * @param required If true and the symbol is not in this library, an error is thrown.
     */
    inline public function createMovie (symbolName :String, required :Bool = true) :MovieSprite
    {
        return cast createSprite(symbolName, required);
    }

    /**
     * Iterates over all the symbols in this library.
     */
    inline public function iterator () :Iterator<Symbol>
    {
        return _symbols.iterator();
    }

    private var _symbols :Map<String,Symbol>;
}
