//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.xfl;

import haxe.xml.Fast;

import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.math.Matrix;

using flambe.util.Xmls;

class MovieSymbol
    implements Symbol
{
    public var name (getName, null) :String;
    public var layers (default, null) :Array<MovieLayer>;

    public function new (reader :Fast)
    {
        var symbolElement = reader.node.DOMSymbolItem;
        _name = symbolElement.att.name;

        var layerElements = symbolElement
            .node.timeline
            .node.DOMTimeline
            .node.layers
            .nodes.DOMLayer;

        layers = [];
        for (layerElement in layerElements) {
            var layer = new MovieLayer(layerElement);
            layers.push(layer);
        }
    }

    public function getName () :String
    {
        return _name;
    }

    public function createSprite () :Sprite
    {
        return new MovieSprite(this);
    }

    private var _name :String;
}

class MovieLayer
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

    private function getFrames () :Int
    {
        var lastKf = keyframes[keyframes.length - 1];
        return lastKf.index + Std.int(lastKf.duration);
    }
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
