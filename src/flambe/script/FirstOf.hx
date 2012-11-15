package flambe.script;

import flambe.Entity;

using Lambda;

/**
 * An action that manages a list of other actions, running them together in parallel until the
 * first of them finish.
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
        var done = true;
        for (ii in 0..._runningActions.length) {
            var action = _runningActions[ii];
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