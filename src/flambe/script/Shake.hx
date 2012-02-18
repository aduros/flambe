//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Jitter;
import flambe.display.Sprite;
import flambe.math.FMath;

/**
 * Shakes an entity's sprite by jittering its X and Y for a set duration.
 */
class Shake
    implements Action
{
    public function new (strengthX :Float, strengthY :Float, seconds :Float)
    {
        _strengthX = strengthX;
        _strengthY = strengthY;
        _duration = FMath.toInt(1000*seconds);
        _elapsed = 0;
    }

    public function update (dt :Int, actor :Entity) :Bool
    {
        var sprite = actor.get(Sprite);
        if (_jitterX == null) {
            _jitterX = new Jitter(sprite.x._, _strengthX);
            _jitterY = new Jitter(sprite.y._, _strengthY);
            sprite.x.behavior = _jitterX;
            sprite.y.behavior = _jitterY;
        }

        _elapsed += dt;
        if (_elapsed >= _duration) {
            if (sprite.x.behavior == _jitterX) {
                sprite.x._ = _jitterX.base;
            }
            if (sprite.y.behavior == _jitterY) {
                sprite.y._ = _jitterY.base;
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
