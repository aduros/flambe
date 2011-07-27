//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

class Repeat
    implements Action
{
    public function new (action :Action)
    {
        _action = action;
    }

    public function update (dt)
    {
        _action.update(dt);
        return false;
    }

    private var _action :Action;
}
