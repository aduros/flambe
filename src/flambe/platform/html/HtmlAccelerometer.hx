//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import flambe.platform.EventGroup;
import Type;

class HtmlAccelerometer
    implements Accelerometer
{
    /**
     * 
     */
    public var motionSupported (get_motionSupported, null) :Bool;
    /**
     * 
     */
    public var orientationSupported (get_orientationSupported, null) :Bool;
    /** 
    * 
    */
    public var motionChange (default, null) :Signal1<AccelerometerMotion>;
    /** 
    * 
    */
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;

    public function new ()
    {
        orientationUpdate = _orientationUpdate = new HeavySignal1();

        if (orientationSupported) {
            _orientation = new AccelerometerOrientation();

            _orientationUpdate.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    _orientationEventGroup = new EventGroup();
                    _orientationEventGroup.addListener(Lib.window,
                        "deviceorientation", handleAccelerometerOrientation);
                } else {
                    _orientationEventGroup.dispose();
                    _orientationEventGroup = null;
                }
            });
        }

        motionChange = _motionChange = new HeavySignal1();

        if (motionSupported) {
            _motion = new AccelerometerMotion();

            _motionChange.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    _motionEventGroup = new EventGroup();
                    _motionEventGroup.addListener(Lib.window,
                        "devicemotion", handleAccelerometerMotion);
                } else {
                    _motionEventGroup.dispose();
                    _motionEventGroup = null;
                }
            });
        }
    }

    private function get_orientationSupported () :Bool
    {
        return (untyped Lib.window).DeviceOrientationEvent != null;
    }

    private function get_motionSupported () :Bool
    {
        return (untyped Lib.window).DeviceMotionEvent != null;
    }

    private function handleAccelerometerOrientation (event :Dynamic)
    {
        switch ((untyped Lib.window).orientation) {
        case -90:
            _orientation._internal_update(event.gamma, -event.beta, event.alpha);
        case 0:
            _orientation._internal_update(event.beta, event.gamma, event.alpha);
        case 90:
            _orientation._internal_update(-event.gamma, event.beta, event.alpha);
        case 180:
            _orientation._internal_update(-event.beta, -event.gamma, event.alpha);
        }

        orientationUpdate.emit(_orientation);
    }
	
	private function handleAccelerometerMotion (event :Dynamic)
    {
        var acceleration = event.acceleration;
        
        switch ((untyped Lib.window).orientation) {
        case -90:
            _motion._internal_update(acceleration.y, -acceleration.x, acceleration.z);
        case 0:
            _motion._internal_update(acceleration.x, acceleration.y, acceleration.z);
        case 90:
            _motion._internal_update(-acceleration.y, acceleration.x, acceleration.z);
        case 180:
            _motion._internal_update(-acceleration.x, -acceleration.y, acceleration.z);
        }

        motionChange.emit(_motion);
    }

    private var _orientationUpdate :HeavySignal1<AccelerometerOrientation>;
    private var _orientationEventGroup :EventGroup;
    private var _orientation :AccelerometerOrientation;

    private var _motionChange:HeavySignal1<AccelerometerMotion>;
    private var _motionEventGroup :EventGroup;
    private var _motion :AccelerometerMotion;
}
