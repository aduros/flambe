//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.AnimatedFloat;
import flambe.animation.Easing;
import flambe.animation.Tween;
import flambe.Entity;

class AnimateBy
    implements Action
{
    public function new (value :AnimatedFloat, by :Float, seconds :Float, easing :EasingFunction)
    {
        _value = value;
        _by = by;
        _seconds = seconds;
        _easing = easing;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        if (_tween == null) {
            _tween = new Tween(_value._, _value._ + _by, _seconds, _easing);
            _value.behavior = _tween;
            _value.update(dt); // Fake an update to account for this frame
        }
        if (_value.behavior != _tween) {
            _tween = null;
            return true;
        }
        return false;
    }

    private var _tween :Tween;

    private var _value :AnimatedFloat;
    private var _by :Float;
    private var _seconds :Float;
    private var _easing :EasingFunction;
}
