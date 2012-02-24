//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import haxe.xml.Fast;

import flambe.asset.AssetPack;

using flambe.util.Xmls;

class Library
{
    public var name (default, null) :String;

    public var layers (default, null) :Array<MovieLayer>;

    public function new (pack :AssetPack, baseDir :String)
    {
        _symbols = new Hash();
        layers = [];

        var xml = Xml.parse(pack.loadFile(baseDir + "/resources.xml")).firstChild();
        var reader = new Fast(xml);

        var symbolElement = reader.node.movie.node.DOMSymbolItem;
        name = symbolElement.att.name;

        var layerElements = symbolElement
            .node.timeline
            .node.DOMTimeline
            .node.layers
            .nodes.DOMLayer;

        for (movieElement in layerElements) {
            var layer = new MovieLayer(movieElement);
            layers.push(layer);
            _symbols.set(layer.name, layer);
        }

        for (atlasElement in reader.nodes.atlas) {
            // TODO(bruno): Should textures be relative to baseDir?
            var atlas = pack.loadTexture(atlasElement.att.filename);
            for (textureElement in atlasElement.nodes.texture) {
                var image = new MovieImage(textureElement, atlas);
                _symbols.set(image.name, image);
            }
        }

        // Now that all symbols have been parsed, go through keyframes and resolve references
        for (layer in layers) {
            for (kf in layer.keyframes) {
                kf.symbol = _symbols.get(kf.symbolName);
                // layer.symbolName = null;
            }
        }
    }

    public function createSprite (symbolName :String) :Sprite
    {
        var symbol = _symbols.get(symbolName);
        return (symbol != null) ? symbol.createSprite() : null;
    }

    private var _symbols :Hash<Symbol>;
}

private interface Symbol
{
    function createSprite () :Sprite;
}

class MovieImage
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
        return new MovieImageSprite(this);
    }
}

class MovieImageSprite extends Sprite
{
    public function new (symbol :MovieImage)
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

    private var _symbol :MovieImage;
}

class MovieLayer
    implements Symbol
{
    public var name (default, null) :String;
    public var keyframes (default, null) :Array<MovieKeyframe>;
    public var frames (getFrames, null) :Int;

    public function new (reader :Fast)
    {
        name = reader.att.name;

        keyframes = [];
        for (element in reader.node.frames.nodes.DOMFrame) {
            keyframes.push(new MovieKeyframe(element, false));
        }
    }

    public function createSprite () :Sprite
    {
        return new MovieLayerSprite(this);
    }

    private function getFrames () :Int
    {
        var lastKf = keyframes[keyframes.length - 1];
        return lastKf.index + Std.int(lastKf.duration);
    }
}

class MovieLayerSprite extends Sprite
{
    public function new (layer :MovieLayer)
    {
        super();
        _lastFrame = 0;
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
            _displays = [];
            for (kf in _keyframes) {
                var display = new Entity().add(this);
            }
        } else {
            owner.addChild(new Entity().add(lastSymbol.createSprite()));
        }
    }

    public function composeFrame (frame :Int)
    {
        var changedKeyframe = false;
        while (_lastFrame < _keyframes.length - 1 && _keyframes[_lastFrame + 1].index <= frame) {
            ++_lastFrame;
            changedKeyframe = true;
        }

        if (changedKeyframe && _displays != null) {
            // owner.replaceChildAt(_layerIdx, _displays[_lastFrame]);
        }

        var kf = _keyframes[_lastFrame];

        x._ = kf.x;
        y._ = kf.y;
        scaleX._ = kf.scaleX;
        scaleY._ = kf.scaleY;
        rotation._ = kf.rotation;
    }

    // private var _layerIdx :Int;
    private var _keyframes :Array<MovieKeyframe>;

    private var _lastFrame :Int;

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // display is swapped in at keyframe changes. If it doesn't, the display is only added to the
    // parent on layer creation.
    private var _displays :Array<Entity>;
}

class MovieKeyframe
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
            return;
        }

        reader = reader.node.elements;
        if (!reader.hasNode.DOMSymbolInstance) {
            return;
        }

        var instance = reader.node.DOMSymbolInstance;
        symbolName = instance.att.libraryItemName;
        x = reader.getFloatAttr("tx");
        y = reader.getFloatAttr("ty");
        scaleX = 1; // TODO(bruno): Extract from matrix
        scaleY = 1;
        rotation = 0;
    }
}
