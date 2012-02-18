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
    public function new (strengthX :Float, strengthY :Float, duration :Int)
    {
        _strengthX = strengthX;
        _strengthY = strengthY;
        _duration = duration;
        _elapsed = 0;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        var t = actor.get(Transform);
        if (_jitterX == null) {
            _jitterX = new Jitter(t.x._, _strengthX);
            _jitterY = new Jitter(t.y._, _strengthY);
            t.x.behavior = _jitterX;
            t.y.behavior = _jitterY;
        }

        _elapsed += dt;
        if (_elapsed >= _duration) {
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

    private var _strengthX :Float;
    private var _strengthY :Float;
    private var _duration :Int;
}
