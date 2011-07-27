//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import Lambda;

class Parallel
    implements Action
{
    public function new (?actions :Array<Dynamic>)
    {
        _completedActions = [];
        _runningActions = (actions != null) ? actions.copy() : [];
    }

    public function add (action :Action)
    {
        _runningActions.push(action);
    }

    public function remove (action :Action) :Bool
    {
        var idx = _actions.indexOf(action);
        if (idx < 0) {
            return false;
        }
        _actions[idx] = null;
        return true;
    }

    public function removeAll ()
    {
        _runningActions = [];
        _completedActions = [];
    }

    public function update (dt :Int)
    {
        for (ii in 0..._runningActions.length) {
            var action = _runningActions[ii];
            if (action != null && action.update(dt)) {
                _runningActions[ii] = null;
                _completedActions.push(action);
            }
        }

        if (_completedActions.length == _runningActions.length) {
            _runningActions = _completedActions;
            _completedActions = [];
            return true;
        }
        return false;
    }

    private var _runningActions :Array<Action>;
    private var _completedActions :Array<Action>;
}
