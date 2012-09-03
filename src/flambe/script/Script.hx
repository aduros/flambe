//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.util.Disposable;

/**
 * Manages a set of actions that are updated over time. Scripts simplify writing composable
 * animations.
 */
class Script extends Component
{
    public function new ()
    {
        stopAll();
    }

    /**
     * Add an action to this Script.
     * @returns A handle that can be disposed to stop the action.
     */
    public function run (action :Action) :Disposable
    {
        var handle = new Handle(action);
        _handles.push(handle);
        return handle;
    }

    /**
     * Remove all actions from this Script.
     */
    public function stopAll ()
    {
        _handles = [];
    }

    override public function onUpdate (dt :Float)
    {
        var ii = 0;
        while (ii < _handles.length) {
            var handle = _handles[ii];
            if (handle.removed || handle.action.update(dt, owner) >= 0) {
                _handles.splice(ii, 1);
            } else {
                ++ii;
            }
        }
    }

    private var _handles :Array<Handle>;
}

private class Handle
    implements Disposable
{
    public var removed (default, null) :Bool;
    public var action :Action;

    public function new (action :Action)
    {
        removed = false;
        this.action = action;
    }

    public function dispose ()
    {
        removed = true;
        action = null;
    }
}
