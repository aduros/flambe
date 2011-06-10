package flambe.animation;

import flambe.animation.Binding;
import flambe.animation.Easing;
import flambe.util.Signal1;

typedef PFloat = Property<Float>;
typedef PInt = Property<Int>;
typedef PBool = Property<Bool>;

// TODO(bruno): Figure out a way to animate this intelligently
typedef PColor = Property<Int>;

class Property<A>
    implements haxe.rtti.Generic // Generate typed templates in Flash
{
    public var _ (get, set) :A;

    public var updated (default, null) :Signal1<Property<A>>;

    public function new (value :A, ?listener :Listener1<Property<A>>)
    {
        _value = value;
        this.updated = new Signal1(listener);
    }

    inline public function get () :A
    {
        return _value;
    }

    public function set (value :A) :A
    {
        _value = value;
        _behavior = null;
        updated.emit(this);
        return value;
    }

    public function update (dt :Int)
    {
        if (_behavior != null) {
            var v = _behavior.update(dt);
            if (_value != v) {
                _value = v;
                updated.emit(this);
            }
            if (_behavior.isComplete()) {
                _behavior = null;
            }
        }
    }

    public function animateTo (to :A, duration :Int, ?easing :EasingFunction)
    {
        setBehavior(cast new Tween(cast _value, cast to, duration, easing));
    }

    public function animateBy (by :A, duration :Int, ?easing :EasingFunction)
    {
        setBehavior(cast new Tween(cast _value, (cast _value) + (cast by), duration, easing));
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
