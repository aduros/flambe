//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

using Lambda;

class Script extends Component
{
    public function new ()
    {
        stopAll();
    }

    public function run (action :Action)
    {
        _actions.push(action);
    }

    public function stop (action :Action) :Bool
    {
        var idx = _actions.indexOf(action);
        if (idx < 0) {
            return false;
        }
        _actions[idx] = null;
        return true;
    }

    public function stopAll ()
    {
        _actions = [];
    }

    override public function onUpdate (dt :Float)
    {
        var ii = 0;
        while (ii < _actions.length) {
            var action = _actions[ii];
            // Action can be null if stop() was called during iteration
            if (action == null || action.update(dt, owner)) {
                _actions.splice(ii, 1);
            } else {
                ++ii;
            }
        }
    }

    private var _actions :Array<Action>;
}
