package flambe.platform.html;

import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import Type;

import js.Lib;

 /**
 * Basic idea is to conform differences in accelerometer support for each
 * device/platform as much as possible.
 */
class HtmlAccelerometer implements Accelerometer
{
    /** Native orientation of the <i>device</i>, either landscape or portait. */
    private var _deviceNativeOrienation:String;
     /**
     */
    private var _windowOrientation:Float;

    private var _win:Dynamic;

    public function new()
    {
        _win = (untyped Lib.window);

        supported = Type.typeof(_win.orientation) == ValueType.TInt;
        //supported = win.DeviceOrientationEvent != null || win.DeviceMotionEvent != null; 
        
        if (supported)
        {
            if (_win.screen.height > _win.screen.width) //Are relative to native orientation. :)
            {   
                _deviceNativeOrienation = "portrait";
            }
            else
            {
                _deviceNativeOrienation = "landscape";
            }

            if (_win.DeviceOrientationEvent)
            {
                orientation = new AccelerometerOrientation();
                orientationChange = new Signal1();

                _win.addEventListener("deviceorientation", handleAccelerometerOrientation, true);
            }

            if (_win.DeviceMotionEvent)
            {
                motion = new AccelerometerMotion();
                motionChange = new Signal1();
            }

        }

    }

    private function updateOrientation(pitch:Float, roll:Float, azimuth:Float)
    {
        orientation.update(pitch, roll, azimuth);
        orientationChange.emit(orientation);
    }

    private function handleAccelerometerOrientation(event):Void
    {
        _windowOrientation = _win.orientation;

        //switch properties to make them consistent with game orientation as opposed to native device orientation.
        if (_deviceNativeOrienation == "landscape") 
        {
            //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
            if (_windowOrientation == 0 || _windowOrientation == -90)
            {
                updateOrientation(event.beta, -event.gamma, event.alpha);
            }
            else
            {
                updateOrientation(-event.beta, event.gamma, event.alpha);
            }
        }
        else
        {
            //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
            if (_windowOrientation == 0 || _windowOrientation == -90)
            {
                updateOrientation(event.gamma, event.beta, event.alpha);
            }
            else
            {
                updateOrientation(-event.gamma, -event.beta, event.alpha);
            }

        }

        orientationChange.emit(orientation);

    }

    public function die()
    {
        var win = (untyped Lib.window);
        win.removeEventListener("deviceorientation", handleAccelerometerOrientation, true);
    }

    /**
     * Device position relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var orientation(default, null):AccelerometerOrientation;
    /**
     * Device motion relative to window orientation.
     * <code>null</code> if not supported.
     */
    public var motion(default, null):AccelerometerMotion;
    /** 
    * Returns true if either acceleration or orientation are suppored.
    */
    public var supported (default, null) :Bool;
    /** 
    * 
    */
    public var motionChange(default, null): Signal1<AccelerometerMotion>;
    /** 
    * 
    */
    public var orientationChange(default, null): Signal1<AccelerometerOrientation>;

}






