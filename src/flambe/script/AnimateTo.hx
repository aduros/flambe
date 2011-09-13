//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Easing;
import flambe.animation.Property;
import flambe.animation.Tween;
import flambe.Entity;

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

    public function update (dt :Int, actor :Entity) :Bool
    {
        if (_tween == null) {
            _tween = new Tween(property._, to, duration, easing);
            property.setBehavior(_tween);
            property.update(dt); // Fake an update to account for this frame
        }
        if (property.getBehavior() != _tween) {
            _tween = null;
            return true;
        }
        return false;
    }

    private var _tween :Tween;
}
