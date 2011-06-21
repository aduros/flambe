//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.animation;

import flambe.animation.Easing;

class Tween
    implements Behavior<Float>
{
    public var from (default, null) :Float;
    public var to (default, null) :Float;
    public var elapsed (default, null) :Int;
    public var duration (default, null) :Int;
    public var easing (default, null) :EasingFunction;

    public function new (from :Float, to :Float, duration :Int, ?easing :EasingFunction)
    {
        this.from = from;
        this.to = to;
        this.duration = duration;
        this.elapsed = 0;
        this.easing = (easing != null) ? easing : Easing.linear;
    }

    public function update (dt :Int) :Float
    {
        elapsed += dt;

        if (elapsed >= duration) {
            return to;
        } else {
            return from + (to - from)*easing(elapsed/duration);
        }
    }

    public function isComplete () :Bool
    {
        return elapsed >= duration;
    }
}
