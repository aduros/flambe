//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Easing;
import flambe.animation.Tween;
import flambe.display.Transform;
import flambe.Entity;

class MoveBy
    implements Action
{
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var duration (default, null) :Int;
    public var easingX (default, null) :EasingFunction;
    public var easingY (default, null) :EasingFunction;

    public function new (
        x :Float, y :Float, duration :Int, easingX :EasingFunction, ?easingY :EasingFunction)
    {
        this.x = x;
        this.y = y;
        this.duration = duration;
        this.easingX = easingX;
        this.easingY = easingY;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        var transform = actor.get(Transform);
        if (_tweenX == null) {
            _tweenX = new Tween(transform.x._, transform.x._ + x, duration, easingX);
            transform.x.setBehavior(_tweenX);
            transform.x.update(dt); // Fake an update to account for this frame

            _tweenY = new Tween(transform.y._, transform.y._ + y, duration,
                (easingY != null) ? easingY : easingX);
            transform.y.setBehavior(_tweenY);
            transform.y.update(dt); // Fake an update to account for this frame
        }
        if (transform.x.getBehavior() != _tweenX && transform.y.getBehavior() != _tweenY) {
            _tweenX = null;
            _tweenY = null;
            return true;
        }
        return false;
    }

    private var _tweenX :Tween;
    private var _tweenY :Tween;
}
