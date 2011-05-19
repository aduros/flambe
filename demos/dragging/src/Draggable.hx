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
        _offset = owner.get(Sprite).getViewMatrix().inverseTransformPoint(
            event.viewX, event.viewY);
    }

    override public function onUpdate (dt :Int)
    {
        if (Input.isMouseDown && _dragging) {
            var xform = owner.get(Transform);
            xform.x.set(Input.mouseX - _offset.x);
            xform.y.set(Input.mouseY - _offset.y);
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
