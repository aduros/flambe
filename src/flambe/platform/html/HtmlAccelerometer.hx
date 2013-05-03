package flambe.platform.html;

import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.util.SignalConnection;
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

        _win = (untyped Lib.window);

        //motionSupported = _win.DeviceMotionEvent != null; 
        orientationSupported = _win.DeviceOrientationEvent != null; 

        // if (motionSupported)
        // {
        //     motion = new AccelerometerMotion();
        //     motionChange = new NotifyingSignal1();

        //     motionUpdate = _motionUpdate = new NotifyingSignal1();

        //     _motionUpdate.addedFirst.connect(function()
        //         {
        //             _motion = new AccelerometerMotion();

        //             _motionEventGroup = new EventGroup();
        //             _motionEventGroup.addListener(_win, "devicemotion", handleAccelerometerMotion);
        //         }
        //     );

        //     _motionUpdate.disposedLast.connect(function()
        //         {
        //             _motion = null;

        //             _motionEventGroup.dispose();
        //             _motionEventGroup = null;
        //         }
        //     );
        // }

        if (orientationSupported)
        {

            orientationUpdate = _orientationUpdate = new NotifyingSignal1();

            _orientationUpdate.addedFirst.connect(function()
                {
                    _orientation = new AccelerometerOrientation();

                    _orientationEventGroup = new EventGroup();
                    _orientationEventGroup.addListener(_win, "deviceorientation", handleAccelerometerOrientation);
                }
            );

            _orientationUpdate.disposedLast.connect(function()
                {
                    _orientation = null;

                    _motionEventGroup.dispose();
                    _motionEventGroup = null;
                }
            );
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

    //private var _motionUpdate:NotifyingSignal1<AccelerometerOrientation>;
    private var _orientationUpdate:NotifyingSignal1<AccelerometerOrientation>;
    private var _windowOrientation:Float;
    private var _win:Dynamic;
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







