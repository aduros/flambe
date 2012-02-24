//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import haxe.xml.Fast;

import flambe.asset.AssetPack;
import flambe.math.FMath;
import flambe.math.Matrix;

using flambe.util.Xmls;

// TODO(bruno): Split this up into multiple files

class Library
{
    public var name (default, null) :String;

    public function new (pack :AssetPack, baseDir :String)
    {
        _symbols = new Hash();

        var xml = Xml.parse(pack.loadFile(baseDir + "/resources.xml")).firstChild();
        var reader = new Fast(xml);

        for (movieElement in reader.nodes.movie) {
            var movie = new MovieSymbol(movieElement);
            _symbols.set(movie.name, movie);
        }

        for (atlasElement in reader.nodes.atlas) {
            // TODO(bruno): Should textures be relative to baseDir?
            var atlas = pack.loadTexture(atlasElement.att.filename);
            for (textureElement in atlasElement.nodes.texture) {
                var image = new ImageSymbol(textureElement, atlas);
                _symbols.set(image.name, image);
            }
        }

        // Now that all symbols have been parsed, go through keyframes and resolve references
        for (symbol in _symbols) {
            symbol.init(this);
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

    private var _symbols :Hash<Symbol>;
}

private interface Symbol
{
    function createSprite () :Sprite;

    function init (library :Library) :Void;
}

class MovieSymbol
    implements Symbol
{
    public var name (default, null) :String;
    public var layers (default, null) :Array<Layer>;

    public function new (reader :Fast)
    {
        var symbolElement = reader.node.DOMSymbolItem;
        name = symbolElement.att.name;

        var layerElements = symbolElement
            .node.timeline
            .node.DOMTimeline
            .node.layers
            .nodes.DOMLayer;

        layers = [];
        for (layerElement in layerElements) {
            var layer = new Layer(layerElement);
            layers.push(layer);
        }
    }

    public function createSprite () :Sprite
    {
        return new MovieSprite(this);
    }

    public function init (lib :Library)
    {
        for (layer in layers) {
            for (kf in layer.keyframes) {
                kf.symbol = lib.symbol(kf.symbolName);
            }
        }
    }
}

class ImageSymbol
    implements Symbol
{
    public var name (default, null) :String;
    public var atlas (default, null) :Texture;
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var width (default, null) :Float;
    public var height (default, null) :Float;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (reader :Fast, atlas :Texture)
    {
        name = reader.att.name;

        this.atlas = atlas;
        x = reader.getFloatAttr("xAtlas");
        y = reader.getFloatAttr("yAtlas");
        width = reader.getFloatAttr("wAtlas");
        height = reader.getFloatAttr("hAtlas");
        anchorX = -reader.getFloatAttr("xOffset");
        anchorY = -reader.getFloatAttr("yOffset");
    }

    public function createSprite () :Sprite
    {
        return new ImageSymbolSprite(this);
    }

    public function init (lib :Library)
    {
        // Nothing
    }
}

class ImageSymbolSprite extends Sprite
{
    public function new (symbol :ImageSymbol)
    {
        super();
        _symbol = symbol;
        anchorX._ = _symbol.anchorX;
        anchorY._ = _symbol.anchorY;
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawSubImage(_symbol.atlas, -anchorX._, -anchorY._,
            _symbol.x, _symbol.y, _symbol.width, _symbol.height);
    }

    override public function getNaturalWidth () :Float
    {
        return _symbol.width;
    }

    override public function getNaturalHeight () :Float
    {
        return _symbol.height;
    }

    private var _symbol :ImageSymbol;
}

class Layer
{
    public var name (default, null) :String;
    public var keyframes (default, null) :Array<Keyframe>;
    public var frames (getFrames, null) :Int;

    public function new (reader :Fast)
    {
        name = reader.att.name;

        keyframes = [];
        for (element in reader.node.frames.nodes.DOMFrame) {
            keyframes.push(new Keyframe(element, false));
        }
    }

    public function createSprite () :Sprite
    {
        return new LayerSprite(this);
    }

    private function getFrames () :Int
    {
        var lastKf = keyframes[keyframes.length - 1];
        return lastKf.index + Std.int(lastKf.duration);
    }
}

class LayerSprite extends Sprite
{
    public var changedKeyframe :Bool;
    public var lastFrame :Int;

    public function new (layer :Layer)
    {
        super();
        changedKeyframe = false;
        lastFrame = 0;
        _keyframes = layer.keyframes;
    }

    override public function onAdded ()
    {
        var lastSymbol = null;
        for (kf in _keyframes) {
            if (kf.symbol != null) {
                lastSymbol = kf.symbol;
                break;
            }
        }

        var multipleSymbols = false;
        for (kf in _keyframes) {
            if (kf.symbol != lastSymbol) {
                multipleSymbols = true;
                break;
            }
        }

        if (multipleSymbols) {
            // _displays = [];
            // for (kf in _keyframes) {
            //     var display = new Entity().add(this);
            // }
        } else if (lastSymbol != null) {
            owner.addChild(new Entity().add(lastSymbol.createSprite()));
        }
    }

    public function composeFrame (frame :Int)
    {
        while (lastFrame < _keyframes.length - 1 && _keyframes[lastFrame + 1].index <= frame) {
            ++lastFrame;
            changedKeyframe = true;
        }

        if (changedKeyframe && _displays != null) {
            // owner.replaceChildAt(_layerIdx, _displays[lastFrame]);
        }

        var kf = _keyframes[lastFrame];

        if (lastFrame == _keyframes.length - 1 || kf.index == frame) {
            x._ = kf.x;
            y._ = kf.y;
            scaleX._ = kf.scaleX;
            scaleY._ = kf.scaleY;
            rotation._ = kf.rotation;

        } else {
            var interp = (frame - kf.index)/kf.duration;
            var nextKf = _keyframes[lastFrame + 1];
            x._ = kf.x + (nextKf.x - kf.x) * interp;
            y._ = kf.y + (nextKf.y - kf.y) * interp;
            scaleX._ = kf.scaleX + (nextKf.scaleX - kf.scaleX) * interp;
            scaleY._ = kf.scaleY + (nextKf.scaleY - kf.scaleY) * interp;
            rotation._ = kf.rotation + (nextKf.rotation - kf.rotation) * interp;
        }
    }

    // private var _layerIdx :Int;
    private var _keyframes :Array<Keyframe>;

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // display is swapped in at keyframe changes. If it doesn't, the display is only added to the
    // parent on layer creation.
    private var _displays :Array<Entity>;
}

private class Keyframe
{
    public var index (default, null) :Int;

    /** The length of this keyframe in frames. */
    public var duration (default, null) :Float;

    public var symbolName (default, null) :String;
    public var symbol :Symbol;

    public var label (default, null) :String;

    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var scaleX (default, null) :Float;
    public var scaleY (default, null) :Float;
    public var rotation (default, null) :Float;

    public function new (reader :Fast, flipbook :Bool)
    {
        index = reader.getIntAttr("index");
        duration = reader.getFloatAttr("duration");
        label = reader.getStringAttr("name");

        if (flipbook) {
            return; // Purely labelled frame
        }

        reader = reader.node.elements;
        if (!reader.hasNode.DOMSymbolInstance) {
            return;
        }

        reader = reader.node.DOMSymbolInstance;
        symbolName = reader.att.libraryItemName;

        if (!reader.hasNode.matrix) {
            x = 0;
            y = 0;
            scaleX = 1;
            scaleY = 1;
            rotation = 0;
            return;
        }

        reader = reader.node.matrix.node.Matrix;
        x = reader.getFloatAttr("tx");
        y = reader.getFloatAttr("ty");

        var matrix = new flambe.math.Matrix();
        matrix.m00 = reader.getFloatAttr("a", 1);
        matrix.m10 = reader.getFloatAttr("b");
        matrix.m01 = reader.getFloatAttr("c");
        matrix.m11 = reader.getFloatAttr("d", 1);

        scaleX = Math.sqrt(matrix.m00*matrix.m00 + matrix.m10*matrix.m10);
        scaleY = Math.sqrt(matrix.m01*matrix.m01 + matrix.m11*matrix.m11);

        var p = matrix.transformPoint(1, 0);
        rotation = FMath.toDegrees(Math.atan2(p.y, p.x));
    }
}
