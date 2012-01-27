//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.Component;
import flambe.display.Sprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Point;
import flambe.System;
import flambe.util.SignalConnection;

class Draggable extends Component
{
    public function new ()
    {
    }

    private function onPointerDown (event :PointerEvent)
    {
        _dragging = true;
        var xform = owner.get(Transform);
        _offset = new Point(event.viewX - xform.x._, event.viewY - xform.y._);
    }

    override public function onUpdate (dt :Int)
    {
        if (_dragging) {
            if (System.input.isPointerDown()) {
                var xform = owner.get(Transform);
                xform.x._ = System.input.pointerX - _offset.x;
                xform.y._ = System.input.pointerY - _offset.y;
            } else {
                _dragging = false;
            }
        }
    }

    override public function onAdded ()
    {
        _connection = owner.get(Sprite).pointerDown.connect(onPointerDown);
    }

    override public function onRemoved ()
    {
        _connection.dispose();
    }

    private var _connection :SignalConnection;
    private var _dragging :Bool;
    private var _offset :Point;
}
