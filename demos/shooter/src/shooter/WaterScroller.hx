//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.animation.Property;
import flambe.Component;
import flambe.display.Transform;

class WaterScroller extends Component
{
    public var speed :PFloat;

    public function new (speed)
    {
        this.speed = new PFloat(speed);
    }

    override public function onUpdate (dt)
    {
        speed.update(dt);

        var transform = owner.get(Transform);
        transform.y._ += dt*speed._;
        while (transform.y._ > 0) {
            transform.y._ -= 32;
        }
    }
}
