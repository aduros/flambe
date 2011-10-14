//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.Component;
import flambe.display.Transform;
import flambe.System;

class SwarmerAI extends Component
{
    public function new ()
    {
        _angleX = Math.random();
        _angleY = Math.random();
    }

    override public function onUpdate (dt)
    {
        var t = owner.get(Transform);
        var w = System.stage.width/2;
        var h = System.stage.height/2;
        t.x._ = w + Math.cos(_angleX) * w;
        t.y._ = h + Math.sin(_angleY) * h;
        t.rotation._ = -45*Math.cos(_angleX);
        _angleX += dt*0.0043*0.3;
        _angleY += dt*0.0018*0.3;
    }

    private var _angleX :Float;
    private var _angleY :Float;
}
