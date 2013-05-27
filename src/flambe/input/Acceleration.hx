//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * <p>A 3D vector that represents the linear acceleration being applied to the device.</p>
 *
 * <p><img src="https://aduros.com/flambe/images/Axes.png"></p>
 */
class Acceleration
{
    /** The acceleration on the X-axis, in m/s^2. */
    public var x (default, null) :Float;

    /** The acceleration on the Y-axis, in m/s^2. */
    public var y (default, null) :Float;

    /** The acceleration on the Z-axis, in m/s^2. */
    public var z (default, null) :Float;

    /**
     * Whether this acceleration vector includes the pull of gravity. Gravity is normally excluded,
     * but some devices may be forced to include it due to lack of gyroscope.
     */
    public var includesGravity (default, null) :Bool;

    @:allow(flambe) function new ()
    {
        init(0, 0, 0, false);
    }

    @:allow(flambe) function init (x :Float, y :Float, z :Float, includesGravity :Bool)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.includesGravity = includesGravity;
    }
}
