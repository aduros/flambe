//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.TouchPoint;
import flambe.subsystem.TouchSystem;
import flambe.util.Signal1;

class DummyTouch
    implements TouchSystem
{
    public var supported (get, null) :Bool;
    public var maxPoints (get, null) :Int;
    public var points (get, null) :Array<TouchPoint>;

    public var down (default, null) :Signal1<TouchPoint>;
    public var move (default, null) :Signal1<TouchPoint>;
    public var up (default, null) :Signal1<TouchPoint>;

    public function new ()
    {
        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
    }

    public function get_supported () :Bool
    {
        return false;
    }

    public function get_maxPoints () :Int
    {
        return 0;
    }

    public function get_points () :Array<TouchPoint>
    {
        return [];
    }
}
