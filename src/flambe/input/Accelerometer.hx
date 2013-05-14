//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

/**
 * <p>Functions related to the device's accelerometer.</p>
 *
 * <p>NOTE: Not yet supported in Flash/AIR.</p>
 */
interface Accelerometer
{
    /**
     * <p>Whether device motion events are supported.</p>
     */
    public var motionSupported (get_motionSupported, null) :Bool;

    /*
     * <p>Emitted upon detected changes in device motion.</p>
     */
    public var motionChange (default, null) :Signal1<AccelerometerMotion>;

    /**
     * <p>Whether device orientation events are supported.</p>
     */
    public var orientationSupported (get_orientationSupported, null) :Bool;

    /**
     * <p>Emitted on regular interval with the current device orientation.</p>
     */
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;
}

class AccelerometerFloat
{   
    public var _ (default, null):Float;

    /** @private */ public function new () {}

    /** @private */ public function _internal_set_value(value:Float):Void
    {
        _ = value;
    }
}

class AccelerometerDelta
{   
    public var x (default, null):Float;
    public var y (default, null):Float;
    public var z (default, null):Float;

    /** @private */ public function new () {}

    /** @private */ public function _internal_set_xyz (x:Float, y:Float, z:Float):Void
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}