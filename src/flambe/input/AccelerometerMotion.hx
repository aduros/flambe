//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Value;

// TODO: Document/implement
/** @private */
class AccelerometerMotion
{
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var z (default, null) :Float;

    /** @private */ public function new ()
    {
        _internal_update(0, 0, 0);
    }

    /** @private */ public function _internal_update (x :Float, y :Float, z :Float)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}
