//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.animation.AnimatedFloat;

/**
 * Adjusts the update speed of an entity (and its components and children). Can be used for slow
 * motion and fast forward effects.
 */
class SpeedAdjuster extends Component
{
    /**
     * The scale that time should pass for the owning entity and its children. Values lower than
     * 1.0 will play slower than realtime, and values higher than 1.0 will play faster. When the
     * scale is 0, the entity is basically paused.
     */
    public var scale (default, null) :AnimatedFloat;

    public function new (scale :Float = 1)
    {
        this.scale = new AnimatedFloat(scale);
    }

    override public function onUpdate (dt :Float)
    {
        // Ensure this component is immune to its own time scaling
        if (_internal_realDt > 0) {
            dt = _internal_realDt;
            _internal_realDt = 0;
        }

        scale.update(dt);
    }

    /** @private */ public var _internal_realDt :Float = 0;
}
