//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

using Lambda;
using flambe.util.Arrays;

/**
 * An action that manages a list of other actions, running them together in parallel until they all
 * finish.
 */
class Parallel
    implements Action
{
    public function new<A:Action> (?actions :Array<A>)
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

    public function update (dt :Float, actor :Entity) :Float
    {
        var done = true;
        var maxSpent = 0.0;
        for (ii in 0..._runningActions.length) {
            var action = _runningActions[ii];
            if (action != null) {
                var spent = action.update(dt, actor);
                if (spent >= 0) {
                    _runningActions[ii] = null;
                    _completedActions.push(action);
                    if (spent > maxSpent) {
                        maxSpent = spent;
                    }
                } else {
                    // We can't possibly finish this frame, but continue ticking the rest of the
                    // actions anyways
                    done = false;
                }
            }
        }

        if (done) {
            _runningActions = _completedActions;
            _completedActions = [];
            return maxSpent;
        }
        return -1;
    }

    private var _runningActions :Array<Action>;
    private var _completedActions :Array<Action>;
}
