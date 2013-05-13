//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Accelerometer;
import flambe.input.AccelerometerOrientation;
import flambe.input.AccelerometerMotion;
import flambe.util.Signal1;

class DummyAccelerometer
    implements Accelerometer
{
    public var orientationSupported (get_orientationSupported, null) :Bool;
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;

    public var motionSupported (get_motionSupported, null) :Bool;
    public var motionChange (default, null) :Signal1<AccelerometerMotion>;

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
