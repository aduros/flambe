//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.Component;
import flambe.display.MouseEvent;
import flambe.display.Sprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.Input;
import flambe.math.Point;

import flambe.util.SignalConnection;

class Draggable extends Component
{
    public function new ()
    {
    }

    private function onMouseDown (event :MouseEvent)
    {
        _dragging = true;
        var xform = owner.get(Transform);
        _offset = new Point(event.viewX - xform.x._, event.viewY - xform.y._);
    }

    override public function onUpdate (dt :Int)
    {
        if (Input.isMouseDown && _dragging) {
            var xform = owner.get(Transform);
            xform.x._ = Input.mouseX - _offset.x;
            xform.y._ = Input.mouseY - _offset.y;
        } else {
            _dragging = false;
        }
    }

    override public function onAdded ()
    {
        _connection = owner.get(Sprite).mouseDown.connect(onMouseDown);
    }

    override public function onRemoved ()
    {
        _connection.dispose();
    }

    private var _connection :SignalConnection;
    private var _dragging :Bool;
    private var _offset :Point;
}
