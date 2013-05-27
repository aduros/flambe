//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

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
                    events.addListener(Browser.window, "devicemotion", onDeviceMotion);
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
                    events.addListener(Browser.window, "deviceorientation", onDeviceOrientation);
                } else {
                    events.dispose();
                    events = null;
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
        var acc = event.acceleration;
        var includesGravity = false;

        // Fall back to accelerationIncludingGravity if acceleration isn't available
        if (acc == null) {
            acc = event.accelerationIncludingGravity;
            includesGravity = true;
        }

        switch ((untyped Browser.window).orientation) {
        case -90:
            _sharedAcceleration.init( acc.y, -acc.x, acc.z, includesGravity);
        case 0:
            _sharedAcceleration.init( acc.x,  acc.y, acc.z, includesGravity);
        case 90:
            _sharedAcceleration.init(-acc.y,  acc.x, acc.z, includesGravity);
        case 180:
            _sharedAcceleration.init(-acc.x, -acc.y, acc.z, includesGravity);
        }

        acceleration.emit(_sharedAcceleration);
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

    private var _sharedAcceleration :Acceleration;
    private var _sharedAttitude :Attitude;
}
