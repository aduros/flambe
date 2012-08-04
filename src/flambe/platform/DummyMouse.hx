//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Mouse;
import flambe.input.MouseButton;
import flambe.input.MouseCursor;
import flambe.input.MouseEvent;
import flambe.util.Signal1;

class DummyMouse
    implements Mouse
{
    public var supported (isSupported, null) :Bool;

    public var down (default, null) :Signal1<MouseEvent>;
    public var move (default, null) :Signal1<MouseEvent>;
    public var up (default, null) :Signal1<MouseEvent>;
    public var scroll (default, null) :Signal1<Float>;

    public var x (getX, null) :Float;
    public var y (getY, null) :Float;
    public var cursor (getCursor, setCursor) :MouseCursor;

    public function new ()
    {
        _cursor = Default;
    }

    public function isSupported () :Bool
    {
        return false;
    }

    public function getX () :Float
    {
        return 0;
    }

    public function getY () :Float
    {
        return 0;
    }

    public function isDown (button :MouseButton) :Bool
    {
        return false;
    }

    public function getCursor () :MouseCursor
    {
        return _cursor;
    }

    public function setCursor (cursor :MouseCursor) :MouseCursor
    {
        return _cursor = cursor;
    }

    private var _cursor :MouseCursor;
}
