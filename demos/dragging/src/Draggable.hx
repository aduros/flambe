import flambe.Entity;
import flambe.display.MouseEvent;
import flambe.Component;

using flambe.display.Sprite;

class Draggable extends Component
{
    public function new ()
    {
    }

    private function onMouseDown (event :MouseEvent)
    {
        _dragging = true;
    }

    override public function update (dt :Int)
    {
        if (_dragging) {
            trace("(TODO)");
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
}
