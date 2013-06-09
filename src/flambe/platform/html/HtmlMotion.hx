//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import flambe.input.Acceleration;
import flambe.input.Attitude;
import flambe.subsystem.MotionSystem;
import flambe.util.Signal1;

class HtmlMotion
    implements MotionSystem
{
    public var accelerationSupported (get, null) :Bool;
    public var acceleration (default, null) :Signal1<Acceleration>;
    public var accelerationIncludingGravity (default, null) :Signal1<Acceleration>;

    public var attitudeSupported (get, null) :Bool;
    public var attitude (default, null) :Signal1<Attitude>;

    public function new ()
    {
        var acceleration = new HeavySignal1();
        this.acceleration = acceleration;

        var accelerationIncludingGravity = new HeavySignal1();
        this.accelerationIncludingGravity = accelerationIncludingGravity;

        var attitude = new HeavySignal1();
        this.attitude = attitude;

        if (accelerationSupported) {
            _sharedAcceleration = new Acceleration();
            _sharedAccelerationIncludingGravity = new Acceleration();

            var motionEvents :EventGroup = null;
            var onListenersChanged = function (_,_) {
                if (acceleration.hasListeners() || accelerationIncludingGravity.hasListeners()) {
                    if (motionEvents == null) {
                        // Connected the first listener, add the native event listener
                        motionEvents = new EventGroup();
                        motionEvents.addListener(Browser.window, "devicemotion", onDeviceMotion);
                    }
                } else {
                    if (motionEvents != null) {
                        // Disconnected the last listener, remove the native event listener
                        motionEvents.dispose();
                        motionEvents = null;
                    }
                }
            };
            acceleration.hasListenersValue.changed.connect(onListenersChanged);
            accelerationIncludingGravity.hasListenersValue.changed.connect(onListenersChanged);
        }

        if (attitudeSupported) {
            _sharedAttitude = new Attitude();

            var orientationEvents :EventGroup = null;
            attitude.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    orientationEvents = new EventGroup();
                    orientationEvents.addListener(Browser.window, "deviceorientation", onDeviceOrientation);
                } else {
                    orientationEvents.dispose();
                    orientationEvents = null;
                }
            });
        }
    }

    private function get_accelerationSupported () :Bool
    {
        return (untyped Browser.window).DeviceMotionEvent != null;
    }

    // http://dev.w3.org/geo/api/spec-source-orientation.html#devicemotion
    private function onDeviceMotion (event :DeviceMotionEvent)
    {
        if (event.acceleration != null) {
            initAcceleration(_sharedAcceleration, event.acceleration);
            acceleration.emit(_sharedAcceleration);
        }

        if (event.accelerationIncludingGravity != null) {
            initAcceleration(_sharedAccelerationIncludingGravity,
                event.accelerationIncludingGravity);
            accelerationIncludingGravity.emit(_sharedAccelerationIncludingGravity);
        }
    }

    private function get_attitudeSupported () :Bool
    {
        return (untyped Browser.window).DeviceOrientationEvent != null;
    }

    // http://dev.w3.org/geo/api/spec-source-orientation.html#deviceorientation
    private function onDeviceOrientation (event :DeviceOrientationEvent)
    {
        switch ((untyped Browser.window).orientation) {
        case -90:
            _sharedAttitude.init( event.gamma, -event.beta , event.alpha);
        case 0:
            _sharedAttitude.init( event.beta ,  event.gamma, event.alpha);
        case 90:
            _sharedAttitude.init(-event.gamma,  event.beta , event.alpha);
        case 180:
            _sharedAttitude.init(-event.beta , -event.gamma, event.alpha);
        }

        attitude.emit(_sharedAttitude);
    }

    private static function initAcceleration (acceleration :Acceleration, input :DeviceAcceleration)
    {
        switch ((untyped Browser.window).orientation) {
        case -90:
            acceleration.init( input.y, -input.x, input.z);
        case 0:
            acceleration.init( input.x,  input.y, input.z);
        case 90:
            acceleration.init(-input.y,  input.x, input.z);
        case 180:
            acceleration.init(-input.x, -input.y, input.z);
        }
    }

    private var _sharedAcceleration :Acceleration;
    private var _sharedAccelerationIncludingGravity :Acceleration;
    private var _sharedAttitude :Attitude;
}
