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
    /**
     * The behavior that is currently animating the value, or null if the value is not being
     * animated.
     */
    public var behavior (get, set) :Behavior;

    public function new (value :Float, ?listener :Listener2<Float,Float>)
    {
        super(value, listener);
    }

    override private function set__ (value :Float) :Float
    {
        _behavior = null;
        return super.set__(value);
    }

    public function update (dt :Float)
    {
        if (_behavior != null) {
            super.set__(_behavior.update(dt));
            if (_behavior.isComplete()) {
                _behavior = null;
            }
        }
    }

    /**
     * Animates between the two given values.
     *
     * @param from The initial value.
     * @param to The target value.
     * @param seconds The animation duration, in seconds.
     * @param easing The easing function to use, defaults to `Ease.linear`.
     */
    public function animate (from :Float, to :Float, seconds :Float, ?easing :EaseFunction)
    {
        set__(from);
        animateTo(to, seconds, easing);
    }

    /**
     * Animates between the current value and the given value.
     *
     * @param to The target value.
     * @param seconds The animation duration, in seconds.
     * @param easing The easing function to use, defaults to `Ease.linear`.
     */
    public function animateTo (to :Float, seconds :Float, ?easing :EaseFunction)
    {
        behavior = new Tween(_value, to, seconds, easing);
    }

    /**
     * Animates the current value by the given delta.
     *
     * @param by The delta added to the current value to get the target value.
     * @param seconds The animation duration, in seconds.
     * @param easing The easing function to use, defaults to `Ease.linear`.
     */
    public function animateBy (by :Float, seconds :Float, ?easing :EaseFunction)
    {
        behavior = new Tween(_value, _value + by, seconds, easing);
    }

    inline public function bindTo (to :Value<Float>, ?fn :BindingFunction)
    {
        behavior = new Binding(to, fn);
    }

    private function set_behavior (behavior :Behavior) :Behavior
    {
        _behavior = behavior;
        update(0);
        return behavior;
    }

    inline private function get_behavior () :Behavior
    {
        return _behavior;
    }

    private var _behavior :Behavior = null;

    override function dispose ()
    {
        _behavior = null;
        super.dispose();
    }

    private static var POOL :Pool<AnimatedFloat> = new Pool<AnimatedFloat>(allocate);

    /**
     * Take an AnimatedFloat from the pool. If the pool is empty, a new AnimatedFloat 
     * will be allocated.
     */
    public static function take (value :Float, ?listener :Listener2<Float,Float>) :AnimatedFloat
    {
        var animatedFloat:AnimatedFloat = POOL.take();
        animatedFloat.setValue(value);
        if (listener != null) {
            animatedFloat.changed.connect(listener);
        }
        return animatedFloat;
    }

    /**
     * Put an AnimatedFloat into the pool.
     */
    public static function put (animatedFloat:AnimatedFloat) :AnimatedFloat
    {
        if (animatedFloat != null) {
            animatedFloat.dispose();
            POOL.put(animatedFloat);
        }
        return null;
    }

    private static function allocate () :AnimatedFloat
    {
        return new AnimatedFloat(Math.NaN);
    }
}
