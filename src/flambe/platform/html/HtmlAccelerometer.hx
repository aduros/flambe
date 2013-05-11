//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import flambe.platform.EventGroup;
import flambe.util.Signal1;

class HtmlAccelerometer
    implements Accelerometer
{
    public var orientationSupported (get_orientationSupported, null) :Bool;
    public var orientationUpdate (default, null) :Signal1<AccelerometerOrientation>;

    public function new()
    {
        //motionSupported = _win.DeviceMotionEvent != null; 

        // if (motionSupported)
        // {
        //     _motion = new AccelerometerMotion();

        //     motionChange = _motionChange = new HeavySignal1();

        //     _motionChange.addedFirst.connect(function()
        //         {
        //             _motionEventGroup = new EventGroup();
        //             _motionEventGroup.addListener(_win, "devicemotion", handleAccelerometerMotion);
        //         }
        //     );

        //     _motionChange.disposedLast.connect(function()
        //         {
        //             _motionEventGroup.dispose();
        //             _motionEventGroup = null;
        //         }
        //     );
        // }

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
    }

    private function get_orientationSupported () :Bool
    {
        return (untyped Lib.window).DeviceOrientationEvent != null;
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

    // private var _motionChange:HeavySignal1<AccelerometerOrientation>;
    // private var _motionEventGroup:EventGroup;
    // private var _motion:AccelerometerMotion;

    private var _orientationUpdate :HeavySignal1<AccelerometerOrientation>;
    private var _orientationEventGroup :EventGroup;
    private var _orientation :AccelerometerOrientation;
}
