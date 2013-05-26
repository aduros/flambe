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
    /** Whether device acceleration events are supported. */
    public var accelerationSupported (get_accelerationSupported, null) :Bool;

    /** Periodically emits the device's current linear acceleration. */
    public var acceleration (default, null) :Signal1<Acceleration>;

    /** Whether device orientation (attitude) events are supported. */
    public var attitudeSupported (get_attitudeSupported, null) :Bool;

    /** Periodically emits the device's current attitude. */
    public var attitude (default, null) :Signal1<Attitude>;
}
