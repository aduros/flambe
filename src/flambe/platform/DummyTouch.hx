//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Touch;
import flambe.input.TouchPoint;
import flambe.util.Signal1;

class DummyTouch
    implements Touch
{
    public var supported (isSupported, null) :Bool;
    public var maxPoints (getMaxPoints, null) :Int;
    public var points (getPoints, null) :Array<TouchPoint>;

    public var down (default, null) :Signal1<TouchPoint>;
    public var move (default, null) :Signal1<TouchPoint>;
    public var up (default, null) :Signal1<TouchPoint>;

    public function new ()
    {
        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
    }

    public function isSupported () :Bool
    {
        return false;
    }

    public function getMaxPoints () :Int
    {
        return 0;
    }

    public function getPoints () :Array<TouchPoint>
    {
        return [];
    }
}
