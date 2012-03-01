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

    /** The total number of frames in this movie. */
    public var frames (default, null) :Int;

    public function new (reader :Fast)
    {
        var symbolElement = reader.node.DOMSymbolItem;
        _name = symbolElement.att.name;

        var layerElements = symbolElement
            .node.timeline
            .node.DOMTimeline
            .node.layers
            .nodes.DOMLayer;

        frames = 0;
        layers = [];
        for (layerElement in layerElements) {
            var layer = new MovieLayer(layerElement);
            frames = cast Math.max(layer.frames, frames);
            layers.unshift(layer);
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

    /** The symbol in the last keyframe that has one, or null if there are no symbol keyframes. */
    public var lastSymbol :Symbol;

    /** True if this layer contains keyframes with at least two different symbols. */
    public var multipleSymbols :Bool;

    public function new (reader :Fast)
    {
        name = reader.att.name;
        multipleSymbols = false;

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
    public var duration (default, null) :Int;

    public var symbolName (default, null) :String;
    public var symbol :Symbol;

    public var label (default, null) :String;

    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var scaleX (default, null) :Float;
    public var scaleY (default, null) :Float;
    public var rotation (default, null) :Float;

    public var alpha (default, null) :Float;

    public function new (reader :Fast, flipbook :Bool)
    {
        index = reader.getIntAttr("index");
        duration = reader.getIntAttr("duration", 1);
        label = reader.getStringAttr("name");

        x = 0;
        y = 0;
        scaleX = 1;
        scaleY = 1;
        rotation = 0;
        alpha = 1;

        if (flipbook) {
            return; // Purely labelled frame
        }

        reader = reader.node.elements;
        if (!reader.hasNode.DOMSymbolInstance) {
            return;
        }

        reader = reader.node.DOMSymbolInstance;
        symbolName = reader.att.libraryItemName;

        if (reader.hasNode.matrix) {
            var matrixElement = reader.node.matrix.node.Matrix;
            x = matrixElement.getFloatAttr("tx");
            y = matrixElement.getFloatAttr("ty");

            var matrix = new Matrix();
            matrix.m00 = matrixElement.getFloatAttr("a", 1);
            matrix.m10 = matrixElement.getFloatAttr("b");
            matrix.m01 = matrixElement.getFloatAttr("c");
            matrix.m11 = matrixElement.getFloatAttr("d", 1);

            scaleX = Math.sqrt(matrix.m00*matrix.m00 + matrix.m10*matrix.m10);
            scaleY = Math.sqrt(matrix.m01*matrix.m01 + matrix.m11*matrix.m11);

            var p = matrix.transformPoint(1, 0);
            rotation = FMath.toDegrees(Math.atan2(p.y, p.x));
        }

        if (reader.hasNode.color) {
            var colorElement = reader.node.color.node.Color;
            alpha = colorElement.getFloatAttr("alphaMultiplier", 1);
        }
    }
}
