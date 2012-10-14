//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

/**
 * An action that repeats another action until it finishes a certain number of times.
 */
class Repeat
    implements Action
{
    /**
     * @param count The number of times to repeat the action, or -1 to repeat forever.
     */
    public function new (action :Action, count :Int = -1)
    {
        _action = action;
        _count = count;
        _remaining = count;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        if (_count == 0) {
            // Handle the special case of a 0-count Repeat
            return 0;
        }

        var spent = _action.update(dt, actor);
        if (_count > 0 && spent >= 0 && --_remaining == 0) {
            _remaining = _count; // Reset state in case this Action is reused
            return spent;
        }

        // Keep repeating
        return -1;
    }

    private var _action :Action;

    private var _count :Int;
    private var _remaining :Int;
}
