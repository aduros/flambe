//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.animation.Easing;

class Tween
    implements Behavior
{
    public function new (from :Float, to :Float, seconds :Float, ?easing :EasingFunction)
    {
        _from = from;
        _to = to;
        _duration = Std.int(1000*seconds);
        _elapsed = 0;
        _easing = (easing != null) ? easing : Easing.linear;
    }

    public function update (dt :Int) :Float
    {
        _elapsed += dt;

        if (_elapsed >= _duration) {
            return _to;
        } else {
            return _from + (_to - _from)*_easing(_elapsed/_duration);
        }
    }

    public function isComplete () :Bool
    {
        return _elapsed >= _duration;
    }

    private var _from :Float;
    private var _to :Float;
    private var _elapsed :Int;
    private var _duration :Int;
    private var _easing :EasingFunction;
}
