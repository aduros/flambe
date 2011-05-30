package shooter;

import flambe.Component;
import flambe.display.Transform;
import flambe.Entity;
import flambe.Input;

class FollowMouse extends Component
{
    public function new ()
    {
    }

    override public function onAdded (owner :Entity)
    {
        super.onAdded(owner);

        // TODO: Free signal
        Input.mouseMove.add(function (event) {
            var t = owner.get(Transform);
            t.x.set(event.viewX);
            t.y.set(event.viewY);
        });
    }
}
