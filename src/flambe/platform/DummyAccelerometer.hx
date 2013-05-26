//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Accelerometer;
import flambe.input.Acceleration;
import flambe.input.Attitude;
import flambe.util.Signal1;

class DummyAccelerometer
    implements Accelerometer
{
    public var accelerationSupported (get_accelerationSupported, null) :Bool;
    public var acceleration (default, null) :Signal1<Acceleration>;

    public var attitudeSupported (get_attitudeSupported, null) :Bool;
    public var attitude (default, null) :Signal1<Attitude>;

    public function new ()
    {
        acceleration = new Signal1();
        attitude = new Signal1();
    }

    private function get_accelerationSupported () :Bool
    {
        return false;
    }

    private function get_attitudeSupported () :Bool
    {
        return false;
    }
}
