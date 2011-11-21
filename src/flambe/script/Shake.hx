//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Jitter;
import flambe.display.Transform;

/**
 * Shakes an entity's transform by jittering its X and Y for a set duration.
 */
class Shake
    implements Action
{
    public var strengthX (default, null) :Float;
    public var strengthY (default, null) :Float;
    public var duration (default, null) :Int;

    public function new (strengthX :Float, strengthY :Float, duration :Int)
    {
        this.strengthX = strengthX;
        this.strengthY = strengthY;
        this.duration = duration;
        _elapsed = 0;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        var t = actor.get(Transform);
        if (_jitterX == null) {
            _jitterX = new Jitter(t.x._, strengthX);
            _jitterY = new Jitter(t.y._, strengthY);
            t.x.behavior = _jitterX;
            t.y.behavior = _jitterY;
        }

        _elapsed += dt;
        if (_elapsed >= duration) {
            if (t.x.behavior == _jitterX) {
                t.x._ = _jitterX.base;
            }
            if (t.y.behavior == _jitterY) {
                t.y._ = _jitterY.base;
            }
            _jitterX = null;
            _jitterY = null;
            _elapsed = 0;
            return true;
        }
        return false;
    }

    private var _elapsed :Int;
    private var _jitterX :Jitter;
    private var _jitterY :Jitter;
}
