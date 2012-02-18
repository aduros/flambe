//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.animation.Property;
import flambe.Component;
import flambe.display.Sprite;

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

        var sprite = owner.get(Sprite);
        sprite.y._ += dt*speed._;
        while (sprite.y._ > 0) {
            sprite.y._ -= 32;
        }
    }
}
