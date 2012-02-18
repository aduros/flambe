//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.Component;
import flambe.display.Sprite;
import flambe.System;

class BomberAI extends Component
{
    public function new ()
    {
    }

    override public function onUpdate (dt)
    {
        var sprite = owner.get(Sprite);
        sprite.y._ += dt*0.05;
        if (sprite.y._ > System.stage.height) {
            owner.dispose();
        }
    }
}
