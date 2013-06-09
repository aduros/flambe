//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.TouchPoint;
import flambe.subsystem.TouchSystem;
import flambe.util.Signal1;

class BasicTouch
    implements TouchSystem
{
    public var supported (get, null) :Bool;
    public var maxPoints (get, null) :Int;
    public var points (get, null) :Array<TouchPoint>;

    public var down (default, null) :Signal1<TouchPoint>;
    public var move (default, null) :Signal1<TouchPoint>;
    public var up (default, null) :Signal1<TouchPoint>;

    public function new (pointer :BasicPointer, maxPoints :Int = 4)
    {
        _pointer = pointer;
        _maxPoints = maxPoints;
        _pointMap = new Map();
        _points = [];

        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
    }

    public function get_supported () :Bool
    {
        return true;
    }

    public function get_maxPoints () :Int
    {
        return _maxPoints;
    }

    public function get_points () :Array<TouchPoint>
    {
        return _points.copy();
    }

    public function submitDown (id :Int, viewX :Float, viewY :Float)
    {
        if (!_pointMap.exists(id)) {
            var point = new TouchPoint(id);
            point.init(viewX, viewY);
            _pointMap.set(id, point);
            _points.push(point);

            if (_pointerTouch == null) {
                // Make this touch point the tracked pointer
                _pointerTouch = point;
                _pointer.submitDown(viewX, viewY, point._source);
            }
            down.emit(point);
        }
    }

    public function submitMove (id :Int, viewX :Float, viewY :Float)
    {
        var point = _pointMap.get(id);
        if (point != null) {
            point.init(viewX, viewY);

            if (_pointerTouch == point) {
                _pointer.submitMove(viewX, viewY, point._source);
            }
            move.emit(point);
        }
    }

    public function submitUp (id :Int, viewX :Float, viewY :Float)
    {
        var point = _pointMap.get(id);
        if (point != null) {
            point.init(viewX, viewY);
            _pointMap.remove(id);
            _points.remove(point);

            if (_pointerTouch == point) {
                _pointerTouch = null;
                _pointer.submitUp(viewX, viewY, point._source);
            }
            up.emit(point);
        }
    }

    private var _pointer :BasicPointer;
    private var _pointerTouch :TouchPoint;

    private var _maxPoints :Int;
    private var _pointMap :Map<Int,TouchPoint>;
    private var _points :Array<TouchPoint>;
}
