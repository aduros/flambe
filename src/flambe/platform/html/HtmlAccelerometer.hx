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
    public var orientationSupported (default, null) :Bool;
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

        _eventGroup = new EventGroup();

        _win = (untyped Lib.window);

        //motionSupported = _win.DeviceMotionEvent != null; 
        orientationSupported = _win.DeviceOrientationEvent != null; 

        // if (motionSupported)
        // {
        //     motion = new AccelerometerMotion();
        //     motionChange = new Signal1();
        // }

        if (orientationSupported)
        {
            _orientation = new AccelerometerOrientation();
            orientationUpdate = new Signal1();

            _eventGroup.addListener(_win, "deviceorientation", handleAccelerometerOrientation);

        }

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
            _orientation.update(event.gamma, -event.beta, event.alpha);
        }
        else if (_windowOrientation == 0)
        {
            _orientation.update(event.beta, event.gamma, event.alpha);
        }
        else if (_windowOrientation == 90)
        {
            _orientation.update(-event.gamma, event.beta, event.alpha);
        }
        else if (_windowOrientation == 180)
        {
            _orientation.update(-event.beta, -event.gamma, event.alpha);
        }
        // else
        // {
        //     trace("Window orientation " + _windowOrientation + " not valid.");
        // }

        orientationUpdate.emit(_orientation);

    }

    /**
     * 
     */
    private function stop()
    {
        _eventGroup.dispose();
        _eventGroup = null;
    }

    private var _windowOrientation:Float;
    private var _win:Dynamic;
    private var _eventGroup:EventGroup;
    private var _orientation:AccelerometerOrientation;
    private var _motion:AccelerometerMotion;
}






