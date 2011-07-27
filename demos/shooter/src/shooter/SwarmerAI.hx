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
        var w = System.stageWidth/2;
        var h = System.stageHeight/2;
        t.x.set(w + Math.cos(_angleX) * w);
        t.y.set(h + Math.sin(_angleY) * h);
        t.rotation.set(-45*Math.cos(_angleX));
        _angleX += dt*0.0043*0.3;
        _angleY += dt*0.0018*0.3;

        //var pt = Game.player.get(Transform);
        //var dx = t.x.get() - pt.x.get();
        //var dy = t.y.get() - pt.y.get();
        //if (dx*dx + dy*dy < 900) {
        //    Game.player.destroy();
        //    Game.player = null;
        //}
    }

    private var _angleX :Float;
    private var _angleY :Float;
}
