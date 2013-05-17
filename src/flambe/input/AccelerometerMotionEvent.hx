//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.input.Accelerometer;

class AccelerometerMotionEvent
{
    /**
     * <p>The acceleration (x, y, z) that the user is giving to the device.</p>
     */
    public var acceleration (default, null) :AccelerometerDeltaXYZ;
    /**
     * <p>The total acceleration (x, y, z) of the device, which includes the user acceleration and the gravity.</p>
     */
    public var accelerationIncludingGravity (default, null) :AccelerometerDeltaXYZ;
    /**
     * <p>A holder for the interval in milliseconds since the last device motion event. <code>null</code> when not available.</p>
     */
    //public var interval :AccelerometerFloat;
    /**
     * <p>A holder for the rotation rate of the device. <code>null</code> when not available.</p>
     */
    //public var rotationRate :AccelerometerFloat;

    /** @private */ public function new()
    {
        acceleration = new AccelerometerDeltaXYZ();
        accelerationIncludingGravity = new AccelerometerDeltaXYZ();

        // interval = null;
        // rotationRate = null;

        _internal_update(0, 0, 0, 0, 0, 0);
    }

    /** @private * / public function _internal_update_interval (value:Float):Void
    {
        if (interval == null)
        {
            interval = new AccelerometerFloat();
        }

        interval._internal_set_value(value);
    }

    / ** @private * / public function _internal_update_rotation_rate (value:Float):Void
    {
        if (rotationRate == null)
        {
            rotationRate = new AccelerometerFloat();
        }

        rotationRate._internal_set_value(value);
    }*/

    /** @private */ public function _internal_update(aX:Float, aY:Float, aZ:Float, aicX:Float, aicY:Float, aicZ:Float):Void
    {
        acceleration._internal_set_xyz(aX, aY, aZ);
        accelerationIncludingGravity._internal_set_xyz(aicX, aicY, aicZ);
    }
}