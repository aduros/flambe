//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.animation;

typedef BindingFunction<A> = A -> A;

class Binding<A>
    implements Behavior<A>
{
    public function new (target :Property<A>, ?fn :BindingFunction<A>)
    {
        _target = target;
        _fn = fn;
    }

    public function update (dt :Int) :A
    {
        var value = _target.get();
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

    private var _target :Property<A>;
    private var _fn :BindingFunction<A>;
}
