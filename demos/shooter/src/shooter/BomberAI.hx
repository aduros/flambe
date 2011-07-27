//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.Component;
import flambe.display.Transform;
import flambe.System;

class BomberAI extends Component
{
    public function new ()
    {
    }

    override public function onUpdate (dt)
    {
        var t = owner.get(Transform);
        t.y.set(t.y.get() + dt*0.05);
        if (t.y.get() > System.stageHeight) {
            owner.dispose();
        }
    }
}
