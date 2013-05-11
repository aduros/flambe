//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal0;
import flambe.util.Signal1;

/**
 * <p>Functions related to the device's accelerometer.</p>
 *
 * <p>NOTE: Not yet supported in Flash/AIR.</p>
 */
interface Accelerometer
{
    // /**
    //  * Whether device motion events are supported.
    //  */
    //public var motionSupported (default, null) :Bool;//TODO

    // /*
    //  * Device motions updates.
    //  */
    //public var motionChange(default, null): Signal1<AccelerometerMotion>;//TODO
    /*
     * Device orientation updates, not to be confused with window orientation.
     */

    /**
     * Whether device orientation events are supported.
     */
    public var orientationSupported (get_orientationSupported, null) :Bool;

    /**
     * Emitted periodically with the current device orientation.
     */
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;
}
