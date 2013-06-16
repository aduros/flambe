package flambe.script;

import flambe.Entity;

using Lambda;
using flambe.util.Arrays;

/**
 * An action that manages a list of other actions, running them together in parallel until the
 * first of them finishes.
 */
class FirstOf
    implements Action
{
    public function new<A:Action> (?actions :Array<A>)
    {
        _runningActions = (actions != null) ? cast actions.copy() : [];
    }

    public function add (action :Action)
    {
        _runningActions.push(action);
    }

    public function remove (action :Action) :Bool
    {
        var idx = _runningActions.indexOf(action);
        if (idx < 0) {
            return false;
        }
        _runningActions[idx] = null;
        return true;
    }

    public function removeAll ()
    {
        _runningActions = [];
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        for (action in _runningActions) {
            if (action != null) {
                var spent = action.update(dt, actor);
                if (spent >= 0) {
                    return spent;
                }
            }
        }

        return -1;
    }

    private var _runningActions :Array<Action>;
}
