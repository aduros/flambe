//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Acceleration;
import flambe.input.Attitude;
import flambe.subsystem.MotionSystem;
import flambe.util.Signal1;

class DummyMotion
    implements MotionSystem
{
    public var accelerationSupported (get, null) :Bool;
    public var acceleration (default, null) :Signal1<Acceleration>;
    public var accelerationIncludingGravity (default, null) :Signal1<Acceleration>;

    public var attitudeSupported (get, null) :Bool;
    public var attitude (default, null) :Signal1<Attitude>;

    public function new ()
    {
        acceleration = new Signal1();
        accelerationIncludingGravity = new Signal1();
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
