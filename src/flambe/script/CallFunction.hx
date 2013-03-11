//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

/**
 * An action that calls a given function once and immediately completes.
 */
class CallFunction
    implements Action
{
    /**
     * @param fn The function to call when this action is run.
     */
    public function new (fn :Void -> Void)
    {
        _fn = fn;
    }

    public function update (dt :Float, actor :Entity)
    {
        _fn();
        return 0;
    }

    private var _fn :Void -> Void;
}
