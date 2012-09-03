//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

/**
 * An action that simply waits for a certain amount of time to pass before finishing.
 */
class Delay
    implements Action
{
    public function new (seconds :Float)
    {
        _duration = seconds;
        _elapsed = 0;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        _elapsed += dt;
        if (_elapsed >= _duration) {
            var overtime = _elapsed - _duration;
            _elapsed = 0;
            return dt - overtime;
        }
        return -1;
    }

    private var _duration :Float;
    private var _elapsed :Float;
}
