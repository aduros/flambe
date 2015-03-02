//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

using Lambda;
using flambe.util.Arrays;

/**
 * An action that manages a list of other actions, running them one-by-one sequentially until they
 * all finish.
 */
class Sequence
    implements Action
{
    public function new<A:Action> (?actions :Array<A>)
    {
        _idx = 0;
        _runningActions = (actions != null) ? cast actions.copy() : [];
    }

    public function add (action :Action) :Sequence
    {
        _runningActions.push(action);
        return this;
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
        _idx = 0;
        _runningActions = [];
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        // The total time taken by the actions updated this frame
        var total = 0.0;

        while (true) {
            var action = _runningActions[_idx];
            if (action != null) {
                var spent = action.update(dt-total, actor);
                if (spent >= 0) {
                    // This action completed, add it to the total time
                    total += spent;
                } else {
                    // This action didn't complete, so neither will this sequence
                    return -1;
                }
            }

            ++_idx;
            if (_idx >= _runningActions.length) {
                // If this is the last action, reset to the starting position and finish
                _idx = 0;
                break;

            } else if (total > dt) {
                // Otherwise, if there are still actions but not enough time to complete them
                return -1;
            }
        }

        return total;
    }

    private var _runningActions :Array<Action>;
    private var _idx :Int;
}
