package flambe.platform.flash;

import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import Type;

import flash.external.ExternalInterface;
import flash.system.Capabilities;

 /**
 * So far, the only major mobile platform that supports Flash is Windows/IE, which currently
 * does not support accelerometer events out of the box. Leaving this for now.
 *
 * Basic idea is to conform differences in accelerometer support for each
 * device/platform as much as possible.
 */
class FlashAccelerometer implements Accelerometer
{
    /** Native orientation of the <i>device</i>, either landscape or portait. */
    private var _deviceNativeOrienation:String;
    /**  */
    private var _windowOrientation:Float;

     /**
     */
    public function new()
    {
        // var cap = Capabilities;

        // if (ExternalInterface.available)
        // {   
        //     var ret:Dynamic = ExternalInterface.call('
        //         function() {
        //              win.orientation
        //             //return Boolean(window.DeviceOrientationEvent || window.DeviceMotionEvent);
        //         }
        //     ');

        //     supported = Type.typeof(ret) == ValueType.TFloat;

        //     if (supported)
        //     {

            //     var literal:String = "function() {return window.orientation}";

            //     var ret:Dynamic = ExternalInterface.call(literal);



            //     // if (cap.screenResolutionY < cap.screenResolutionX)
            //     // {
            //     //     if (_windowOrientation == 90)
            //     //     {   
            //     //         _deviceNativeOrienation = "portrait";
            //     //     }
            //     //     else
            //     //     {
            //     //         _deviceNativeOrienation = "landscape";
            //     //     }
            //     // }
            //     // else
            //     // {
            //     //     if (_windowOrientation != 90)
            //     //     {   
            //     //         _deviceNativeOrienation = "portrait";
            //     //     }
            //     //     else
            //     //     {
            //     //         _deviceNativeOrienation = "landscape";
            //     //     }
            //     //     //TODO, this may need to be done every time the window rotates in 
            //     //     //Windows Metro, but we don't really know yet, because accelerometer
            //     //     //is not implemented yet.

            //     // }

            //     if (cap.screenResolutionY < cap.screenResolutionX) //Should be relative to native orientation?
            //     {   
            //         _deviceNativeOrienation = "portrait";
            //     }
            //     else
            //     {
            //         _deviceNativeOrienation = "landscape";
            //     }


            //     ExternalInterface.addCallback('handleOrientation', handleAccelerometerOrientation);

            //     if (ExternalInterface.call('function() {return Boolean(window.DeviceOrientationEvent)}') != false)
            //     {
            //         orientation = new AccelerometerOrientation();
            //         orientationChange = new Signal1();

            //         var func:String = '
            //             function(e) {
            //                ' + getSWFObjectName() + '.handleOrientation(e.alpha, e.beta, e.gamma);
            //             }
            //         ';

            //         var js:String ='
            //             function() {
            //                 window.flambe_handleDeviceOrientation = ' + func + '
            //                 window.addEventListener("deviceorientation", flambe_handleDeviceOrientation, true);
            //             }
            //         ';

            //     }

            //     if (ExternalInterface.call('function() {return Boolean(window.DeviceMotionEvent)}') != false)
            //     {
            //         motion = new AccelerometerMotion();
            //         motionChange = new Signal1();
            //     }

            //}

        // }
        // else
        // {
        //     throw("ExternalInterface must be available for Accelerometer use.");
        // }

    }

    private function getSWFObjectName(): String {
        // Returns the SWF's object name for getElementById

        // Based on https://github.com/millermedeiros/Hasher_AS3_helper/blob/master/dev/src/org/osflash/hasher/Hasher.as
        var ret:Dynamic = ExternalInterface.call('
            function() {
                 win.orientation
                //return Boolean(window.DeviceOrientationEvent || window.DeviceMotionEvent);
            }
        ');
 
        _windowOrientation = cast(ret, Float);
     
        var js:String = '
            function(__randomFunction) {
                var check = function(objects) {
                    for (var i = 0; i < objects.length; i++){
                        if (objects[i][__randomFunction]) return objects[i].id;
                    }
                    return undefined;
                };
                return check(document.getElementsByTagName("object")) || check(document.getElementsByTagName("embed"));
            }
        ';
                
        var __randomFunction:String = "checkFunction_" + Math.floor(Math.random() * 99999); // Something random just so it's safer
        ExternalInterface.addCallback(__randomFunction, getSWFObjectName); // The second parameter can be anything, just passing a function that exists
                
        return ExternalInterface.call(js, __randomFunction);
    }

    
    private function updateOrientation(pitch:Float, roll:Float, azimuth:Float)
    {
        orientation.update(pitch, roll, azimuth);
        orientationChange.emit(orientation);
    }

    private function handleAccelerometerOrientation(alpha:Float, beta:Float, gamma:Float):Void
    {
        //var win = (untyped Lib.window);
        //var windowOrientation = win.orientation;

        if (_deviceNativeOrienation == "landscape") 
        {
            //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
            if (_windowOrientation == 0 || _windowOrientation == -90)
            {
                updateOrientation(beta, -gamma, alpha);
            }
            else
            {
                updateOrientation(-beta, gamma, alpha);
            }
        }
        else
        {
            //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
            if (_windowOrientation == 0 || _windowOrientation == -90)
            {
                updateOrientation(gamma, beta, alpha);
            }
            else
            {
                updateOrientation(-gamma, -beta, alpha);
            }

        }

        orientationChange.emit(orientation);

    }

    public function die()
    {

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






