//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.input.Acceleration;
import flambe.input.Attitude;
import flambe.input.Motion;
import flambe.util.Signal1;

class HtmlMotion
    implements Motion
{
    public var accelerationSupported (get_accelerationSupported, null) :Bool;
    public var acceleration (default, null) :Signal1<Acceleration>;

    public var attitudeSupported (get_attitudeSupported, null) :Bool;
    public var attitude (default, null) :Signal1<Attitude>;

    public function new ()
    {
        var accelerationHeavy = new HeavySignal1();
        this.acceleration = accelerationHeavy;
        if (accelerationSupported) {
            _sharedAcceleration = new Acceleration();

            var events :EventGroup = null;
            accelerationHeavy.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    events = new EventGroup();
                    events.addListener(Lib.window, "devicemotion", onDeviceMotion);
                } else {
                    events.dispose();
                    events = null;
                }
            });
        }

        var attitudeHeavy = new HeavySignal1();
        this.attitude = attitudeHeavy;
        if (attitudeSupported) {
            _sharedAttitude = new Attitude();

            var events :EventGroup = null;
            attitudeHeavy.hasListenersValue.changed.connect(function (hasListeners,_) {
                if (hasListeners) {
                    events = new EventGroup();
                    events.addListener(Lib.window, "deviceorientation", onDeviceOrientation);
                } else {
                    events.dispose();
                    events = null;
                }
            });
        }
    }

    private function get_accelerationSupported () :Bool
    {
        return (untyped Lib.window).DeviceMotionEvent != null;
    }

    // http://dev.w3.org/geo/api/spec-source-orientation.html#devicemotion
    private function onDeviceMotion (event :Dynamic)
    {
        var acc :Dynamic = event.acceleration;
        var includesGravity = false;

        // Fall back to accelerationIncludingGravity if acceleration isn't available
        if (acc == null) {
            acc = event.accelerationIncludingGravity;
            includesGravity = true;
        }

        switch ((untyped Lib.window).orientation) {
        case -90:
            _sharedAcceleration._internal_init( acc.y, -acc.x, acc.z, includesGravity);
        case 0:
            _sharedAcceleration._internal_init( acc.x,  acc.y, acc.z, includesGravity);
        case 90:
            _sharedAcceleration._internal_init(-acc.y,  acc.x, acc.z, includesGravity);
        case 180:
            _sharedAcceleration._internal_init(-acc.x, -acc.y, acc.z, includesGravity);
        }

        acceleration.emit(_sharedAcceleration);
    }

    private function get_attitudeSupported () :Bool
    {
        return (untyped Lib.window).DeviceOrientationEvent != null;
    }

    // http://dev.w3.org/geo/api/spec-source-orientation.html#deviceorientation
    private function onDeviceOrientation (event :Dynamic)
    {
        switch ((untyped Lib.window).orientation) {
        case -90:
            _sharedAttitude._internal_init( event.gamma, -event.beta , event.alpha);
        case 0:
            _sharedAttitude._internal_init( event.beta ,  event.gamma, event.alpha);
        case 90:
            _sharedAttitude._internal_init(-event.gamma,  event.beta , event.alpha);
        case 180:
            _sharedAttitude._internal_init(-event.beta , -event.gamma, event.alpha);
        }

        attitude.emit(_sharedAttitude);
    }

    private var _sharedAcceleration :Acceleration;
    private var _sharedAttitude :Attitude;
}
