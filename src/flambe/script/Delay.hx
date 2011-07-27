//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

class Delay
    implements Action
{
    public function new (duration :Float)
    {
        _duration = 1000*duration;
        _elapsed = 0;
    }

    public function update (dt)
    {
        _elapsed += dt;
        if (_elapsed >= _duration) {
            _elapsed = 0;
            return true;
        }
        return false;
    }

    private var _duration :Float;
    private var _elapsed :Int;
}
