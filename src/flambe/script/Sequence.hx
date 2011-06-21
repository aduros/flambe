//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

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
        throw "TODO";
        return false;
    }

    public function removeAll ()
    {
        _idx = 0;
        _runningActions = [];
    }

    public function update (dt :Int) :Bool
    {
        if (_idx >= _runningActions.length ||
            (_runningActions[_idx].update(dt) && ++_idx >= _runningActions.length)) {
            _idx = 0;
            return true;
        }
        return false;
    }

    private var _runningActions :Array<Action>;
    private var _idx :Int;
}
