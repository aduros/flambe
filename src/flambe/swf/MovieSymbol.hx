//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.swf.Format;

/**
 * Defines a Flump movie.
 */
class MovieSymbol
    implements Symbol
{
    public var name (get_name, null) :String;

    public var layers (default, null) :Array<MovieLayer>;

    /**
     * The total number of frames in this movie.
     */
    public var frames (default, null) :Int;

    /**
     * The rate that this movie is played, in frames per second.
     */
    public var frameRate (default, null) :Float;

    /**
     * The duration of this animation in seconds.
     */
    public var duration (default, null) :Float;

    public function new (lib :Library, reader :MovieFormat)
    {
        _name = reader.id;
        frameRate = lib.frameRate;

        frames = 0;
        layers = [];
        for (layerObject in reader.layers) {
            var layer = new MovieLayer(layerObject);
            frames = cast Math.max(layer.frames, frames);
            layers.push(layer);
        }
        duration = frames / frameRate;
    }

    public function get_name () :String
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
    public var frames (get_frames, null) :Int;

    /** The symbol in the last keyframe that has one, or null if there are no symbol keyframes. */
    public var lastSymbol :Symbol = null;

    /** True if this layer contains keyframes with at least two different symbols. */
    public var multipleSymbols :Bool = false;

    public function new (reader :LayerFormat)
    {
        name = reader.name;

        keyframes = [];
        var prevKf = null;
        for (keyframeObject in reader.keyframes) {
            prevKf = new MovieKeyframe(keyframeObject, prevKf);
            keyframes.push(prevKf);
        }
    }

    private function get_frames () :Int
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
    public var symbol :Symbol = null;

    public var label (default, null) :String;

    public var x (default, null) :Float = 0;
    public var y (default, null) :Float = 0;
    public var scaleX (default, null) :Float = 1;
    public var scaleY (default, null) :Float = 1;
    public var skewX (default, null) :Float = 0;
    public var skewY (default, null) :Float = 0;

    public var pivotX (default, null) :Float = 0;
    public var pivotY (default, null) :Float = 0;

    public var alpha (default, null) :Float = 1;

    public var visible (default, null) :Bool = true;

    /** Whether this keyframe should be tweened to the next. */
    public var tweened (default, null) :Bool = true;

    /** Easing amount, if tweened is true. */
    public var ease (default, null) :Float = 0;

    public function new (reader :KeyframeFormat, prevKf :MovieKeyframe)
    {
        index = (prevKf != null) ? prevKf.index + prevKf.duration : 0;

        duration = reader.duration;
        label = reader.label;
        symbolName = reader.ref;

        var loc = reader.loc;
        if (loc != null) {
            x = loc[0];
            y = loc[1];
        }

        var scale = reader.scale;
        if (scale != null) {
            scaleX = scale[0];
            scaleY = scale[1];
        }

        var skew = reader.skew;
        if (skew != null) {
            skewX = skew[0];
            skewY = skew[1];
        }

        var pivot = reader.pivot;
        if (pivot != null) {
            pivotX = pivot[0];
            pivotY = pivot[1];
        }

        if (reader.alpha != null) {
            alpha = reader.alpha;
        }

        if (reader.visible != null) {
            visible = reader.visible;
        }

        if (reader.tweened != null) {
            tweened = reader.tweened;
        }

        if (reader.ease != null) {
            ease = reader.ease;
        }
    }
}
