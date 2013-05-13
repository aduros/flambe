//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.input.Accelerometer;
import flambe.input.AccelerometerMotion;
import flambe.input.AccelerometerOrientation;
import flambe.platform.EventGroup;
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

    /**
     *
     */
    public function new()
    {

        //Coming back to this. It's very outdated, and was never in working order!

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

            //     ExternalInterface.addCallback('handleOrientation', handleAccelerometerOrientation);

            //     if (ExternalInterface.call('function() {return Boolean(window.DeviceOrientationEvent)}') != false)
            //     {
            //         _orientation = new AccelerometerOrientation();
            //         orientation = new Signal1();

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
            //         _motion = new AccelerometerMotion();
            //         motion = new Signal1();
            //     }

            //}

        // }
        // else
        // {
        //     throw("ExternalInterface must be available for Accelerometer use.");
        // }

    }

    private function get_orientationSupported () :Bool
    {
        return false;
    }

    private function get_motionSupported () :Bool
    {
        return false;
    }

    /**
     *
     */
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

    /**
     *
     */
    private function handleAccelerometerOrientation(alpha:Float, beta:Float, gamma:Float):Void
    {
        //_windowOrientation = _win.orientation;

        //alpha = z = azimuth, beta = x = pitch, gamma = y = roll
        if (_windowOrientation == -90)
        {
            orientation._internal_update(event.gamma, -event.beta, event.alpha);
        }
        else if (_windowOrientation == 0)
        {
            orientation._internal_update(event.beta, event.gamma, event.alpha);
        }
        else if (_windowOrientation == 90)
        {
            orientation._internal_update(-event.gamma, event.beta, event.alpha);
        }
        else if (_windowOrientation == 180)
        {
            orientation._internal_update(-event.beta, -event.gamma, event.alpha);
        }
        // else
        // {
        //     trace("Window orientation " + _windowOrientation + " not valid.");
        // }

        orientationUpdate.emit(orientation);

    }

    private var _motionUpdate:HeavySignal1<AccelerometerOrientation>;
    private var _orientationUpdate:HeavySignal1<AccelerometerOrientation>;
    private var _windowOrientation:Float;
    private var _orientationEventGroup:EventGroup;
    private var _motionEventGroup:EventGroup;
    private var _motion:AccelerometerMotion;
    private var _orientation:AccelerometerOrientation;
}
