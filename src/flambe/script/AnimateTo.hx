package flambe.script;

import flambe.animation.Easing;
import flambe.animation.Property;
import flambe.animation.Tween;

class AnimateTo
    implements Action
{
    public var property (default, null) :PFloat;
    public var to (default, null) :Float;
    public var duration (default, null) :Int;
    public var easing (default, null) :EasingFunction;

    public function new (property :PFloat, to :Float, duration :Int, easing :EasingFunction)
    {
        this.property = property;
        this.to = to;
        this.duration = duration;
        this.easing = easing;
    }

    public function update (dt :Int) :Bool
    {
        if (!_didStart) {
            _tween = new Tween(property.get(), to, duration, easing);
            property.setBehavior(_tween);
            property.update(dt); // Fake an update to account for this frame
            _didStart = true;
        }
        if (property.getBehavior() != _tween) {
            _didStart = false;
            return true;
        }
        return false;
    }

    private var _didStart :Bool;
    private var _tween :Tween;
}
