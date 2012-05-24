//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.util.Value;

typedef BindingFunction = Float -> Float;

class Binding
    implements Behavior
{
    public function new (target :Value<Float>, ?fn :BindingFunction)
    {
        _target = target;
        _fn = fn;
    }

    public function update (dt :Float) :Float
    {
        var value = _target._;
        // TODO: Be lazy and only call _fn when the value is changed?
        if (_fn != null) {
            return _fn(value);
        } else {
            return value;
        }
    }

    public function isComplete () :Bool
    {
        return false;
    }

    private var _target :Value<Float>;
    private var _fn :BindingFunction;
}
