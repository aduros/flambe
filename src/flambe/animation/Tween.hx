//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.animation.Ease;

class Tween
    implements Behavior
{
    public var elapsed (default, null) :Float;

    public function new (from :Float, to :Float, seconds :Float, ?easing :EaseFunction)
    {
        _from = from;
        _to = to;
        _duration = seconds;
        elapsed = 0;
        _easing = (easing != null) ? easing : Ease.linear;
    }

    public function update (dt :Float) :Float
    {
        elapsed += dt;

        if (elapsed >= _duration) {
            return _to;
        } else {
            return _from + (_to - _from)*_easing(elapsed/_duration);
        }
    }

    public function isComplete () :Bool
    {
        return elapsed >= _duration;
    }

    private var _from :Float;
    private var _to :Float;
    private var _duration :Float;
    private var _easing :EaseFunction;
}
