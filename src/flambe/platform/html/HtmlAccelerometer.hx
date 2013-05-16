//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotionEvent;
import flambe.input.AccelerometerOrientationEvent;
import flambe.platform.EventGroup;
import Type;

class HtmlAccelerometer
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
        orientationUpdate = _orientationUpdate = new HeavySignal1();

        if (orientationSupported) {
            _orientation = new AccelerometerOrientationEvent();

            _orientationUpdate.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    _orientationEventGroup = new EventGroup();
                    _orientationEventGroup.addListener(Lib.window,
                        "deviceorientation", handleAccelerometerOrientationEvent);
                } else {
                    _orientationEventGroup.dispose();
                    _orientationEventGroup = null;
                }
            });
        }

        motionChange = _motionChange = new HeavySignal1();

        if (motionSupported) {
            _motion = new AccelerometerMotionEvent();

            _motionChange.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    _motionEventGroup = new EventGroup();
                    _motionEventGroup.addListener(Lib.window,
                        "devicemotion", handleAccelerometerMotionEvent);
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

    private function handleAccelerometerOrientationEvent (event :Dynamic):Void
    {
        // var compassAccuracy:Dynamic = (event.compassAccuracy != null) ? event.compassAccuracy : event.webkitCompassAccuracy;
        // var compassHeading:Dynamic = (event.compassHeading != null) ? event.compassHeading : event.webkitCompassHeading;

        // if (compassAccuracy != null)
        // {
        //     _orientation._internal_update_accuracy(compassAccuracy);
        // }

        // if (event.compassHeading != null)
        // {
        //     _orientation._internal_update_heading(compassHeading);
        // }

        switch ((untyped Lib.window).orientation) {
        case -90:
            _orientation._internal_update( event.gamma, -event.beta , event.alpha);
        case 0:
            _orientation._internal_update( event.beta ,  event.gamma, event.alpha);
        case 90:
            _orientation._internal_update(-event.gamma,  event.beta , event.alpha);
        case 180:
            _orientation._internal_update(-event.beta , -event.gamma, event.alpha);
        }

        orientationUpdate.emit(_orientation);
    }
	
	private function handleAccelerometerMotionEvent (event :Dynamic):Void
    {
        var a:Dynamic = event.acceleration;
        var aic:Dynamic = event.accelerationIncludingGravity;
        // var interval:Dynamic = event.interval;
        // var rotationRate:Dynamic = event.rotationRate;
        
        // _motion._internal_update_interval(interval);
        // _motion._internal_update_rotation_rate(rotationRate);

        switch ((untyped Lib.window).orientation) {
        case -90:
            _motion._internal_update( a.y, -a.x, a.z,  aic.y, -aic.x, aic.z);
        case 0:
            _motion._internal_update( a.x,  a.y, a.z,  aic.x,  aic.y, aic.z);
        case 90:
            _motion._internal_update(-a.y,  a.x, a.z, -aic.y,  aic.x, aic.z);
        case 180:
            _motion._internal_update(-a.x, -a.y, a.z, -aic.x, -aic.y, aic.z);
        }

        motionChange.emit(_motion);
    }

    private var _orientationUpdate :HeavySignal1<AccelerometerOrientationEvent>;
    private var _orientationEventGroup :EventGroup;
    private var _orientation :AccelerometerOrientationEvent;

    private var _motionChange :HeavySignal1<AccelerometerMotionEvent>;
    private var _motionEventGroup :EventGroup;
    private var _motion :AccelerometerMotionEvent;
}
