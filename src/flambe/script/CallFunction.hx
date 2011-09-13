//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

class CallFunction
    implements Action
{
    public function new (fn :Void -> Dynamic)
    {
        _fn = fn;
    }

    public function update (dt :Int, actor :Entity)
    {
        _fn();
        return true;
    }

    private var _fn :Void -> Dynamic;
}
