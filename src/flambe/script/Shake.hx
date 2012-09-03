//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.animation.Jitter;
import flambe.display.Sprite;

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
        _duration = seconds;
        _elapsed = 0;
    }

    public function update (dt :Float, actor :Entity) :Float
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
            var overtime = _elapsed - _duration;
            if (sprite.x.behavior == _jitterX) {
                sprite.x._ = _jitterX.base;
            }
            if (sprite.y.behavior == _jitterY) {
                sprite.y._ = _jitterY.base;
            }
            _jitterX = null;
            _jitterY = null;
            _elapsed = 0;
            return dt - overtime;
        }
        return -1;
    }

    private var _elapsed :Float;
    private var _jitterX :Jitter;
    private var _jitterY :Jitter;

    private var _strengthX :Float;
    private var _strengthY :Float;
    private var _duration :Float;
}
