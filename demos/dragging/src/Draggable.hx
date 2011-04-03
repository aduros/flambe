import flambe.Entity;
import flambe.display.MouseEvent;
import flambe.Component;
import flambe.math.Point;
import flambe.Input;

using flambe.display.Sprite;
using flambe.display.Transform;

class Draggable extends Component
{
    public function new ()
    {
    }

    private function onMouseDown (event :MouseEvent)
    {
        _dragging = true;
        _offset = owner.getSprite().getViewMatrix().inverseTransformPoint(
            event.viewX, event.viewY);
    }

    override public function update (dt :Int)
    {
        if (Input.isMouseDown && _dragging) {
            var xform = owner.getTransform();
            xform.x.set(Input.mouseX - _offset.x);
            xform.y.set(Input.mouseY - _offset.y);
        } else {
            _dragging = false;
        }
    }

    override public function onAttach (entity :Entity)
    {
        super.onAttach(entity);
        owner.getSprite().mouseDown.add(onMouseDown);
    }

    override public function onDetach ()
    {
        owner.getSprite().mouseDown.remove(onMouseDown); // FIXME
        super.onDetach();
    }

    private var _dragging :Bool;
    private var _offset :Point;
}
