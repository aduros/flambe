package flambe.platform.html;

import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import flambe.platform.EventGroup;
import Type;

import js.Lib;

 /**
 * Basic idea is to conform differences in accelerometer support for each
 * device/platform as much as possible.
 */
class HtmlAccelerometer implements Accelerometer
{
    /**
     * 
     */
    //public var motionSupported (default, null) :Bool;//TODO
    /**
     * 
     */
    public var orientationSupported (get_orientationSupported, null) :Bool;
    /** 
    * <code>null</code> if not supported.
    */
    //public var motionChange(default, null): Signal1<AccelerometerMotion>;//TODO
    /** 
    * <code>null</code> if not supported.
    */
    public var orientationUpdate(default, null): Signal1<AccelerometerOrientation>;
    /**
     * 
     */
    public var disposed(default, null):Signal0;

    /**
     * 
     */
    public function new()
    {   
        disposed = new Signal0();

        _win = (untyped Lib.window);

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

        if (orientationSupported)
        {
            _orientation = new AccelerometerOrientation();

            orientationUpdate = _orientationUpdate = new HeavySignal1();

            _orientationUpdate.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    _orientationEventGroup = new EventGroup();
                    _orientationEventGroup.addListener(_win, "deviceorientation", handleAccelerometerOrientation);
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

    /**
     * 
     */
    private function handleAccelerometerOrientation(event):Void
    {
        _windowOrientation = _win.orientation;

        //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
        if (_windowOrientation == -90)
        {
            _orientation._internal_update(event.gamma, -event.beta, event.alpha);
        }
        else if (_windowOrientation == 0)
        {
            _orientation._internal_update(event.beta, event.gamma, event.alpha);
        }
        else if (_windowOrientation == 90)
        {
            _orientation._internal_update(-event.gamma, event.beta, event.alpha);
        }
        else if (_windowOrientation == 180)
        {
            _orientation._internal_update(-event.beta, -event.gamma, event.alpha);
        }
        // else
        // {
        //     trace("Window orientation " + _windowOrientation + " not valid.");
        // }

        orientationUpdate.emit(_orientation);

    }

    //private var _motionChange:HeavySignal1<AccelerometerOrientation>;
    private var _orientationUpdate:HeavySignal1<AccelerometerOrientation>;
    private var _windowOrientation:Float;
    private var _win:Dynamic;
    private var _orientationEventGroup:EventGroup;
    private var _motionEventGroup:EventGroup;
    //private var _motion:AccelerometerMotion;
    private var _orientation:AccelerometerOrientation;

}
