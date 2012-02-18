//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Easing;
import flambe.animation.Tween;
import flambe.display.Transform;
import flambe.Entity;
import flambe.math.FMath;

class MoveTo
    implements Action
{
    public function new (
        x :Float, y :Float, seconds :Float, easingX :EasingFunction, ?easingY :EasingFunction)
    {
        _x = x;
        _y = y;
        _duration = FMath.toInt(1000*seconds);
        _easingX = easingX;
        _easingY = easingY;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        var transform = actor.get(Transform);
        if (_tweenX == null) {
            _tweenX = new Tween(transform.x._, _x, _duration, _easingX);
            transform.x.behavior = _tweenX;
            transform.x.update(dt); // Fake an update to account for this frame

            _tweenY = new Tween(transform.y._, _y, _duration,
                (_easingY != null) ? _easingY : _easingX);
            transform.y.behavior = _tweenY;
            transform.y.update(dt); // Fake an update to account for this frame
        }
        if (transform.x.behavior != _tweenX && transform.y.behavior != _tweenY) {
            _tweenX = null;
            _tweenY = null;
            return true;
        }
        return false;
    }

    private var _tweenX :Tween;
    private var _tweenY :Tween;

    private var _x :Float;
    private var _y :Float;
    private var _duration :Int;
    private var _easingX :EasingFunction;
    private var _easingY :EasingFunction;
}
