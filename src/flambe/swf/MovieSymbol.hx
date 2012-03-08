//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.math.Matrix;

import flambe.swf.Format;

class MovieSymbol
    implements Symbol
{
    public var name (getName, null) :String;
    public var layers (default, null) :Array<MovieLayer>;

    /** The total number of frames in this movie. */
    public var frames (default, null) :Int;

    public function new (reader :MovieFormat)
    {
        _name = reader.symbol;
        trace(reader.symbol);

        frames = 0;
        layers = [];
        for (layerObject in reader.layers) {
            var layer = new MovieLayer(layerObject);
            frames = cast Math.max(layer.frames, frames);
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

    /** The symbol in the last keyframe that has one, or null if there are no symbol keyframes. */
    public var lastSymbol :Symbol;

    /** True if this layer contains keyframes with at least two different symbols. */
    public var multipleSymbols :Bool;

    public function new (reader :LayerFormat)
    {
        name = reader.name;
        multipleSymbols = false;

        keyframes = [];
        for (keyframeObject in reader.keyframes) {
            keyframes.push(new MovieKeyframe(keyframeObject, false));
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

    public var pivotX (default, null) :Float;
    public var pivotY (default, null) :Float;

    public var alpha (default, null) :Float;

    public function new (reader :KeyframeFormat, flipbook :Bool)
    {
        index = reader.index;
        duration = reader.duration;
        label = reader.label;
        symbolName = reader.ref;

        x = 0;
        y = 0;
        scaleX = 1;
        scaleY = 1;
        rotation = 0;
        alpha = 1;

        if (flipbook) {
            return; // Purely labelled frame
        }

        if (symbolName == null) {
            return;
        }

        var t = reader.t;
        x = t[0];
        y = t[1];
        scaleX = t[2];
        scaleY = t[3];
        rotation = FMath.toDegrees(t[4]);

        var pivot = reader.pivot;
        pivotX = pivot[0];
        pivotY = pivot[1];

        if (reader.alpha != null) {
            alpha = reader.alpha;
        }
    }
}
