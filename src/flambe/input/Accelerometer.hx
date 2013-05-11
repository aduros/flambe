//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal0;
import flambe.util.Signal1;

interface Accelerometer
{
    /*
     * Returns true if acceleration is suppored.
     */
    //public var motionSupported (default, null) :Bool;//TODO
    /*
     * Returns true if either orientation or orientation are suppored.
     */
    public var orientationSupported (default, null) :Bool;
    /*
     * Device motions updates.
     */
    //public var motionChange(default, null): Signal1<AccelerometerMotion>;//TODO
    /*
     * Device orientation updates, not to be confused with window orientation.
     */
    public var orientationUpdate(default, null): Signal1<AccelerometerOrientation>;

}