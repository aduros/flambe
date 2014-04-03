//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.AnimatedFloat;
import flambe.animation.Ease;
import flambe.animation.Tween;
import flambe.Entity;

/**
 * An action that tweens an AnimatedFloat to a certain value.
 */
class AnimateTo
    implements Action
{
    public function new (value :AnimatedFloat, to :Float, seconds :Float, ?easing :EaseFunction)
    {
        _value = value;
        _to = to;
        _seconds = seconds;
        _easing = easing;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        if (_tween == null) {
            _tween = new Tween(_value._, _to, _seconds, _easing);
            _value.behavior = _tween;
            _value.update(dt); // Fake an update to account for this frame
        }
        if (_value.behavior != _tween) {
            var overtime = _tween.elapsed - _seconds;
            _tween = null;
            return (overtime > 0) ? Math.max(0, dt - overtime) : 0;
        }
        return -1;
    }

    private var _tween :Tween;

    private var _value :AnimatedFloat;
    private var _to :Float;
    private var _seconds :Float;
    private var _easing :EaseFunction;
}
