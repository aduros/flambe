//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.MouseButton;
import flambe.input.MouseCursor;
import flambe.input.MouseEvent;
import flambe.subsystem.MouseSystem;
import flambe.util.Signal1;

class DummyMouse
    implements MouseSystem
{
    public var supported (get, null) :Bool;

    public var down (default, null) :Signal1<MouseEvent>;
    public var move (default, null) :Signal1<MouseEvent>;
    public var up (default, null) :Signal1<MouseEvent>;
    public var scroll (default, null) :Signal1<Float>;

    public var x (get, null) :Float;
    public var y (get, null) :Float;
    public var cursor (get, set) :MouseCursor;

    public function new ()
    {
        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
        scroll = new Signal1();

        _cursor = Default;
    }

    public function get_supported () :Bool
    {
        return false;
    }

    public function get_x () :Float
    {
        return 0;
    }

    public function get_y () :Float
    {
        return 0;
    }

    public function isDown (button :MouseButton) :Bool
    {
        return false;
    }

    public function get_cursor () :MouseCursor
    {
        return _cursor;
    }

    public function set_cursor (cursor :MouseCursor) :MouseCursor
    {
        return _cursor = cursor;
    }

    private var _cursor :MouseCursor;
}
