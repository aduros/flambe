//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

interface Accelerometer
{
    /**
     * Device position relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var orientation(default, null):AccelerometerOrientation;
    /**
     * Device motion relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var motion(default, null):AccelerometerMotion;//TODO
    /** 
    * Returns true if either acceleration or orientation are suppored.
    */
    public var supported (default, null) :Bool;

    public function die():Void;

}