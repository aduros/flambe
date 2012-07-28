//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Mouse;
import flambe.input.MouseButton;
import flambe.input.MouseCursor;
import flambe.input.MouseEvent;
import flambe.input.PointerEvent;
import flambe.util.Signal1;

using flambe.platform.MouseCodes;

class BasicMouse
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

    public function new (pointer :BasicPointer)
    {
        _pointer = pointer;
        _source = Mouse(_sharedEvent);

        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
        scroll = new Signal1();
        _id = 0;
        _x = 0;
        _y = 0;
        _cursor = Default;
        _buttonStates = new IntHash();
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function getX () :Float
    {
        return _x;
    }

    public function getY () :Float
    {
        return _y;
    }

    public function getCursor () :MouseCursor
    {
        return _cursor;
    }

    public function setCursor (cursor :MouseCursor) :MouseCursor
    {
        // See subclasses for implementation
        return _cursor = cursor;
    }

    public function isDown (button :MouseButton) :Bool
    {
        return isCodeDown(button.toButtonCode());
    }

    public function submitDown (viewX :Float, viewY :Float, buttonCode :Int)
    {
        if (!isCodeDown(buttonCode)) {
            _buttonStates.set(buttonCode, true);

            // Init the MouseEvent, and let the Pointer system handle it before emitting our signal
            prepare(viewX, viewY, buttonCode.toButton());
            _pointer.submitDown(viewX, viewY, _source);
            down.emit(_sharedEvent);
        }
    }

    public function submitMove (viewX :Float, viewY :Float)
    {
        prepare(viewX, viewY, null);
        _pointer.submitMove(viewX, viewY, _source);
        move.emit(_sharedEvent);
    }

    public function submitUp (viewX :Float, viewY :Float, buttonCode :Int)
    {
        if (isCodeDown(buttonCode)) {
            _buttonStates.remove(buttonCode);

            prepare(viewX, viewY, buttonCode.toButton());
            _pointer.submitUp(viewX, viewY, _source);
            up.emit(_sharedEvent);
        }
    }

    // Returns true if the scroll signal was handled
    public function submitScroll (viewX :Float, viewY :Float, velocity :Float) :Bool
    {
        _x = viewX;
        _y = viewY;
        if (!scroll.hasListeners()) {
            return false;
        }
        scroll.emit(velocity);
        return true;
    }

    inline private function isCodeDown (buttonCode :Int) :Bool
    {
        return _buttonStates.exists(buttonCode);
    }

    private function submit (signal :Signal1<MouseEvent>,
        viewX :Float, viewY :Float, button :MouseButton)
    {
        _x = viewX;
        _y = viewY;

        if (signal.hasListeners()) {
            _sharedEvent._internal_init(++_id, viewX, viewY, button);
            signal.emit(_sharedEvent);
        }
    }

    private function prepare (viewX :Float, viewY :Float, button :MouseButton)
    {
        _x = viewX;
        _y = viewY;
        _sharedEvent._internal_init(++_id, viewX, viewY, button);
    }

    private static var _sharedEvent = new MouseEvent();

    private var _pointer :BasicPointer;
    private var _source :EventSource;

    private var _id :Int;
    private var _x :Float;
    private var _y :Float;
    private var _cursor :MouseCursor;
    private var _buttonStates :IntHash<Bool>;
}
