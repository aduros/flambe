//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Accelerometer;
import flambe.input.AccelerometerOrientation;
import flambe.util.Signal1;

class DummyAccelerometer
    implements Accelerometer
{
    public var orientationSupported (get_orientationSupported, null) :Bool;
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;

    public function new ()
    {
        orientationUpdate = new Signal1();
    }

    private function get_orientationSupported () :Bool
    {
        return false;
    }
}
