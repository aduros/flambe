//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Accelerometer;
import flambe.input.AccelerometerOrientationEvent;
import flambe.input.AccelerometerMotionEvent;
import flambe.util.Signal1;

class DummyAccelerometer
    implements Accelerometer
{
    /**
     * <p>Whether device motion events are supported.</p>
     */
    public var motionSupported (get_motionSupported, null) :Bool;

    /*
     * <p>Emitted upon detected changes in device motion.</p>
     */
    public var motionChange (default, null) :Signal1<AccelerometerMotionEvent>;

    /**
     * <p>Whether device orientation events are supported.</p>
     */
    public var orientationSupported (get_orientationSupported, null) :Bool;

    /**
     * <p>Emitted on regular interval with the current device orientation.</p>
     */
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientationEvent>;

    public function new ()
    {
        orientationUpdate = new Signal1();
        motionChange = new Signal1();
    }

    private function get_orientationSupported () :Bool
    {
        return false;
    }

    private function get_motionSupported () :Bool
    {
        return false;
    }

}
