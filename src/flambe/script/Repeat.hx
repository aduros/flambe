//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

class Repeat
    implements Action
{
    public function new (action :Action)
    {
        _action = action;
    }

    public function update (dt :Int, actor :Entity)
    {
        _action.update(dt, actor);
        return false; // Repeat forever
    }

    private var _action :Action;
}
