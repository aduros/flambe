//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.animation.Binding;
import flambe.animation.Ease;
import flambe.util.Signal2;
import flambe.util.Value;

/**
 * A Float value that may be animated over time.
 */
class AnimatedFloat extends Value<Float>
{
    public var behavior (getBehavior, setBehavior) :Behavior;

    public function new (value :Float, ?listener :Listener2<Float,Float>)
    {
        super(value, listener);
    }

    override private function set (value :Float) :Float
    {
        _behavior = null;
        return super.set(value);
    }

    public function update (dt :Float)
    {
        if (_behavior != null) {
            super.set(_behavior.update(dt));
            if (_behavior.isComplete()) {
                _behavior = null;
            }
        }
    }

    public function animate (from :Float, to :Float, seconds :Float, ?easing :EaseFunction)
    {
        set(from);
        animateTo(to, seconds, easing);
    }

    public function animateTo (to :Float, seconds :Float, ?easing :EaseFunction)
    {
        setBehavior(new Tween(_value, to, seconds, easing));
    }

    public function animateBy (by :Float, seconds :Float, ?easing :EaseFunction)
    {
        setBehavior(new Tween(_value, _value + by, seconds, easing));
    }

    inline public function bindTo (to :Value<Float>, ?fn :BindingFunction)
    {
        setBehavior(new Binding(to, fn));
    }

    private function setBehavior (behavior :Behavior) :Behavior
    {
        _behavior = behavior;
        update(0);
        return behavior;
    }

    inline private function getBehavior () :Behavior
    {
        return _behavior;
    }

    private var _behavior :Behavior;
}
