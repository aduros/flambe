package flambe.animation;

import flambe.animation.Binding;
import flambe.util.Signal1;

typedef PFloat = Property<Float>;
typedef PInt = Property<Int>;
typedef PBool = Property<Bool>;

class Property<A>
    implements haxe.rtti.Generic // Generate typed templates in Flash
{
    public var onUpdate :Signal1<Property<A>>;

    public function new (value :A, ?listener :Listener1<Property<A>>)
    {
        _value = value;
        this.onUpdate = new Signal1(listener);
    }

    inline public function get () :A
    {
        return _value;
    }

    public function set (value :A)
    {
        _value = value;
        _behavior = null;
        onUpdate.emit(this);
    }

    public function update (dt :Int)
    {
        if (_behavior != null) {
            var v = _behavior.update(dt);
            if (_value != v) {
                _value = v;
                onUpdate.emit(this);
            }
            if (_behavior.isComplete()) {
                _behavior = null;
            }
        }
    }

    inline public function animateTo (to :A, duration :Int)
    {
        setBehavior(cast new Tween(cast _value, cast to, duration));
    }

    inline public function bindTo (to :Property<A>, ?fn :BindingFunction<A>)
    {
        setBehavior(new Binding(to, fn));
    }

    public function setBehavior (behavior :Behavior<A>)
    {
        _behavior = behavior;
        update(0);
    }

    inline public function getBehavior () :Behavior<A>
    {
        return _behavior;
    }

    private var _value :A;
    private var _behavior :Behavior<A>;
}
