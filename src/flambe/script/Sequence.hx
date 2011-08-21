//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

using Lambda;

class Sequence
    implements Action
{
    public function new (?actions :Array<Dynamic>)
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

    public function update (dt :Int) :Bool
    {
        var action = _runningActions[_idx];
        if (action == null || action.update(dt)) {
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
