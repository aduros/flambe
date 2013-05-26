//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

class Acceleration
{
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var z (default, null) :Float;

    /**
     * Whether this acceleration vector includes the pull of gravity. Gravity is normally excluded,
     * but some devices may be forced to include it due to lack of gyroscope.
     */
    public var includesGravity (default, null) :Bool;

    /** @private */ public function new ()
    {
        _internal_init(0, 0, 0, false);
    }

    /** @private */ public function _internal_init (
        x :Float, y :Float, z :Float, includesGravity :Bool)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.includesGravity = includesGravity;
    }
}
