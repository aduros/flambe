//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

class Delay
    implements Action
{
    public function new (seconds :Float)
    {
        _duration = Std.int(1000*seconds);
        _elapsed = 0;
    }

    public function update (dt :Int, actor :Entity)
    {
        _elapsed += dt;
        if (_elapsed >= _duration) {
            _elapsed = 0;
            return true;
        }
        return false;
    }

    private var _duration :Int;
    private var _elapsed :Int;
}
