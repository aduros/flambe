package flambe.platform.flash;

import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.util.SignalConnection;
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

    //private var _motionUpdate:NotifyingSignal1<AccelerometerOrientation>;
    private var _orientationUpdate:NotifyingSignal1<AccelerometerOrientation>;
    private var _windowOrientation:Float;
    private var _orientationEventGroup:EventGroup;
    private var _motionEventGroup:EventGroup;
    //private var _motion:AccelerometerMotion;
    private var _orientation:AccelerometerOrientation;

}

private class NotifyingSignal1<A> extends Signal1<A>
{
    public var disposedLast(default, null):Signal0;
    public var addedFirst(default, null):Signal0;

    public function new (?listener :Listener1<A>)
    {
        super(listener);

        disposedLast = new Signal0();
        addedFirst = new Signal0();
    }

    override public function connect (listener :Listener1<A>, prioritize :Bool = false) :SignalConnection
    {
        if (!hasListeners())
        {
            // Added the first listener.
            addedFirst.emit();
        }

        return super.connect(listener, prioritize);
    }

    override public function _internal_disconnect (conn :SignalConnection)
    {
        super._internal_disconnect(conn);

        if (!hasListeners()) {
            // Disposed the last listener.
            disposedLast.emit();
        }
    }
}






