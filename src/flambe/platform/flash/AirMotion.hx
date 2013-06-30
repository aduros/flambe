//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

import flambe.input.Acceleration;
import flambe.input.Attitude;
import flambe.subsystem.MotionSystem;
import flambe.util.Signal1;

class AirMotion
    implements MotionSystem
{
    public var accelerationSupported (get, null) :Bool;
    public var acceleration (default, null) :Signal1<Acceleration>;
    public var accelerationIncludingGravity (default, null) :Signal1<Acceleration>;

    public var attitudeSupported (get, null) :Bool;
    public var attitude (default, null) :Signal1<Attitude>;

    public static function shouldUse () :Bool
    {
        return Accelerometer.isSupported;
    }

    public function new ()
    {
        acceleration = new Signal1();

        var accelerationIncludingGravity = new HeavySignal1();
        this.accelerationIncludingGravity = accelerationIncludingGravity;

        attitude = new Signal1();

        _sharedAccelerationIncludingGravity = new Acceleration();

        var accelerometer :Accelerometer = null;
        accelerationIncludingGravity.hasListenersValue.changed.connect(function (hasListeners,_) {
            if (hasListeners) {
                accelerometer = new Accelerometer();
                accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
            } else {
                // Allow the listener to be GC'd
                accelerometer.removeEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
                accelerometer = null;
            }
        });
    }

    private function get_accelerationSupported () :Bool
    {
        return true;
    }

    private function onAccelerometerUpdate (event :AccelerometerEvent)
    {
        // TODO(bruno): These values should be normalized to the stage orientation, like HtmlMotion
        _sharedAccelerationIncludingGravity.init(
            G * event.accelerationX,
            G * event.accelerationY,
            G * event.accelerationZ);
        accelerationIncludingGravity.emit(_sharedAccelerationIncludingGravity);
    }

    private function get_attitudeSupported () :Bool
    {
        return false;
    }

    private static inline var G = 9.80665; // ms^2 gravity on Earth

    private var _sharedAccelerationIncludingGravity :Acceleration;
}
