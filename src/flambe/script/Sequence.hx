//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

using Lambda;

/**
 * An action that manages a list of other actions, running them one-by-one sequentially until they
 * all finish.
 */
class Sequence
    implements Action
{
    public function new (?actions :Array<Action>)
    {
        _idx = 0;
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
        _idx = 0;
        _runningActions = [];
    }

    public function update (dt :Float, actor :Entity) :Bool
    {
        var action = _runningActions[_idx];
        if (action == null || action.update(dt, actor)) {
            ++_idx;
            if (_idx >= _runningActions.length) {
                _idx = 0;
                return true;
            }
        }
        return false;
    }

    private var _runningActions :Array<Action>;
    private var _idx :Int;
}
