//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

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
    public var behavior (getBehavior, setBehavior) :Behavior<A>;

    public var updated (getUpdated, null) :Signal1<Property<A>>;

    public function new (value :A, ?listener :Listener1<Property<A>>)
    {
        _value = value;
        if (listener != null) {
            _updated = new Signal1(listener);
        }
    }

    inline public function get () :A
    {
        return _value;
    }

    public function set (value :A) :A
    {
        _value = value;
        _behavior = null;
        if (_updated != null) {
            _updated.emit(this);
        }
        return value;
    }

    public function update (dt :Int)
    {
        if (_behavior != null) {
            var v = _behavior.update(dt);
            if (_value != v) {
                _value = v;
                if (_updated != null) {
                    _updated.emit(this);
                }
            }
            if (_behavior.isComplete()) {
                _behavior = null;
            }
        }
    }

    public function animate (from :A, to :A, seconds :Float, ?easing :EasingFunction)
    {
        set(from);
        animateTo(to, seconds, easing);
    }

    public function animateTo (to :A, seconds :Float, ?easing :EasingFunction)
    {
        setBehavior(cast new Tween(cast _value, cast to, seconds, easing));
    }

    public function animateBy (by :A, seconds :Float, ?easing :EasingFunction)
    {
        setBehavior(cast new Tween(cast _value, (cast _value) + (cast by), seconds, easing));
    }

    inline public function bindTo (to :Property<A>, ?fn :BindingFunction<A>)
    {
        setBehavior(new Binding(to, fn));
    }

    public function setBehavior (behavior :Behavior<A>) :Behavior<A>
    {
        _behavior = behavior;
        update(0);
        return behavior;
    }

    inline public function getBehavior () :Behavior<A>
    {
        return _behavior;
    }

    private function getUpdated ()
    {
        if (_updated == null) {
            _updated = new Signal1();
        }
        return _updated;
    }

#if debug
    public function toString () :String
    {
        return cast _value;
    }
#end

    private var _value :A;
    private var _behavior :Behavior<A>;

    private var _updated :Signal1<Property<A>>;
}
