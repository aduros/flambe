//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.script;

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
        throw "TODO";
        return false;
    }

    public function stopAll ()
    {
        _actions = [];
    }

    override public function onUpdate (dt :Int)
    {
        var ii = 0;
        while (ii < _actions.length) {
            var action = _actions[ii];
            // Action can be null if stop() was called during iteration
            if (action == null || action.update(dt)) {
                _actions.splice(ii, 1);
            } else {
                ++ii;
            }
        }
    }

    private var _actions :Array<Action>;
}
