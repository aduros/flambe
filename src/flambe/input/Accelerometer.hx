//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal0;
import flambe.util.Signal1;

interface Accelerometer
{
    /**
     * Device motion relative to window orientation.
     * <code>null</code> if not supported.
     */
    //public var motion(default, null):AccelerometerMotion;//TODO
    /**
     * Device position relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var orientation(default, null):AccelerometerOrientation;
    /*
     * Returns true if acceleration is suppored.
     */
    //public var motionSupported (default, null) :Bool;//TODO
    /*
     * Returns true if either orientation or orientation are suppored.
     */
    public var orientationSupported (default, null) :Bool;
    /*
     * Kill it.
     */
    public function dispose():Void;
    /*
     * Device motions updates.
     */
    //public var motionChange(default, null): Signal1<AccelerometerMotion>;//TODO
    /*
     * Device orientation updates, not to be confused with window orientation.
     */
    public var orientationChange(default, null): Signal1<AccelerometerOrientation>;
    /*
     * Device orientation updates, not to be confused with window orientation.
     */
    public var disposed(default, null):Signal0;

}