//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Ease;
import flambe.animation.Tween;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;

/**
 * An action that scales the owner's sprite to a certain value.
 */
class ScaleTo
    implements Action
{
    public function new (
        x :Float, y :Float, seconds :Float, ?easingX :EaseFunction, ?easingY :EaseFunction)
    {
        _x = x;
        _y = y;
        _seconds = seconds;
        _easingX = easingX;
        _easingY = easingY;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        var sprite = actor.get(Sprite);
        if (_tweenX == null) {
            _tweenX = new Tween(sprite.scaleX._, _x, _seconds, _easingX);
            sprite.scaleX.behavior = _tweenX;
            sprite.scaleX.update(dt); // Fake an update to account for this frame

            _tweenY = new Tween(sprite.scaleY._, _y, _seconds,
                (_easingY != null) ? _easingY : _easingX);
            sprite.scaleY.behavior = _tweenY;
            sprite.scaleY.update(dt); // Fake an update to account for this frame
        }
        if (sprite.scaleX.behavior != _tweenX && sprite.scaleY.behavior != _tweenY) {
            var overtime = FMath.max(_tweenX.elapsed, _tweenY.elapsed) - _seconds;
            _tweenX = null;
            _tweenY = null;
            return (overtime > 0) ? dt - overtime : 0;
        }
        return -1;
    }

    private var _tweenX :Tween;
    private var _tweenY :Tween;

    private var _x :Float;
    private var _y :Float;
    private var _seconds :Float;
    private var _easingX :EaseFunction;
    private var _easingY :EaseFunction;
}
