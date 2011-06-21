//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.script;

class CallFunction
    implements Action
{
    public function new (fn :Void -> Dynamic)
    {
        _fn = fn;
    }

    public function update (dt)
    {
        _fn();
        return true;
    }

    private var _fn :Void -> Dynamic;
}
