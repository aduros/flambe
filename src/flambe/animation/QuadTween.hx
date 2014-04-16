//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.animation.Ease;

class QuadTween
    implements Behavior
{
    public var elapsed (default, null) :Float;

    public function new (from :Float, control:Float, to :Float, seconds :Float, ?easing :EaseFunction)
    {
        _from = from;
        _control = control;
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
            var t = _easing(elapsed / _duration);
            var q = 1 - t;
            return (q * q) * _from + 2 * q * t * _control + (t * t) * _to;
        }
    }

    public function isComplete () :Bool
    {
        return elapsed >= _duration;
    }

    private var _from :Float;
    private var _control :Float;
    private var _to :Float;
    private var _duration :Float;
    private var _easing :EaseFunction;
}
