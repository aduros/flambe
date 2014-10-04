//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.AnimatedFloat;
import flambe.animation.Ease;
import flambe.animation.Tween;
import flambe.Entity;

/**
 * An action that tweens an AnimatedFloat from a certain value, to a certain value at the mid of the tween, then again to a certain value.
 */
class AnimateFromToThen
    implements Action
{
    public function new (value :AnimatedFloat, from:Float, to :Float, then:Float, seconds :Float, ?easingStart :EaseFunction, ?easingEnd:EaseFunction)
    {
        _value = value;
        _from = from;
        _to = to;
        _then = then;
        _seconds = seconds;
        _easingStart = easingStart;
        _easingEnd = easingEnd;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        if (_tweenStart == null) {
            _tweenStart = new Tween(_from, _to, _seconds * .5, _easingStart);
            _value.behavior = _tweenStart;
            _value.update(dt); // Fake an update to account for this frame
        }
        if (_value.behavior != _tweenStart) {
            if (_tweenEnd == null) {
                _tweenEnd = new Tween(_to, _then, _seconds * .5, _easingEnd);
                _value.behavior = _tweenEnd;
                _value.update(dt); // Fake an update to account for this frame
            }
            if (_value.behavior != _tweenEnd) {
                var overtime = _tweenEnd.elapsed - _seconds;
                _tweenStart = _tweenEnd = null;
                return (overtime > 0) ? dt - overtime : 0;
            }
        }
        return -1;
    }

    private var _tweenStart :Tween;
    private var _tweenEnd :Tween;

    private var _value :AnimatedFloat;
    private var _from :Float;
    private var _to :Float;
    private var _then :Float;
    private var _seconds :Float;
    private var _easingStart :EaseFunction;
    private var _easingEnd :EaseFunction;
}
