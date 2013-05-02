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
     * Device motion relative to window orientation.
     * <code>null</code> if not supported.
     */
    //public var motion(default, null):AccelerometerMotion;//TODO
    /**
     * Device position relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var orientation(default, null):AccelerometerOrientation;
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
    public var orientationChange(default, null): Signal1<AccelerometerOrientation>;
    /**
     * 
     */
    public var disposed(default, null):Signal0;

    /**
     * 
     */
    public function new(platform:Platform)
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
            orientation = new AccelerometerOrientation();
            orientationChange = new Signal1();

            _eventGroup.addListener(_win, "deviceorientation", handleAccelerometerOrientation);

        }

    }

    /**
     * 
     */
    private function updateOrientation(pitch:Float, roll:Float, azimuth:Float)
    {
        orientation.update(pitch, roll, azimuth);
        orientationChange.emit(orientation);
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
            updateOrientation(event.gamma, -event.beta, event.alpha);
        }
        else if (_windowOrientation == 0)
        {
            updateOrientation(event.beta, event.gamma, event.alpha);
        }
        else if (_windowOrientation == 90)
        {
            updateOrientation(-event.gamma, event.beta, event.alpha);
        }
        else if (_windowOrientation == 180)
        {
            updateOrientation(-event.beta, -event.gamma, event.alpha);
        }
        else
        {
            trace("Window orientation " + _windowOrientation + " not valid.");
        }

        orientationChange.emit(orientation);

    }

    /**
     * 
     */
    public function dispose()
    {
        trace('adflajfd');
        _eventGroup.dispose();
        _eventGroup = null;
        orientation = null;
        //motion = null;
        disposed.emit();
        disposed = null;
    }

    private var _windowOrientation:Float;
    private var _win:Dynamic;
    private var _eventGroup:EventGroup;

}






