//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

using Lambda;

/**
 * An action that manages a list of other actions, running them together in parallel until they all
 * finish.
 */
class Parallel
    implements Action
{
    public function new (?actions :Array<Dynamic>)
    {
        _completedActions = [];
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
        _completedActions = [];
    }

    public function update (dt :Float, actor :Entity) :Bool
    {
        var done = true;
        for (ii in 0..._runningActions.length) {
            var action = _runningActions[ii];
            if (action != null) {
                if (action.update(dt, actor)) {
                    _runningActions[ii] = null;
                    _completedActions.push(action);
                } else {
                    done = false;
                }
            }
        }

        if (done) {
            _runningActions = _completedActions;
            _completedActions = [];
            return true;
        }
        return false;
    }

    private var _runningActions :Array<Action>;
    private var _completedActions :Array<Action>;
}
