package shooter;

import flambe.Component;
import flambe.display.Transform;
import flambe.Entity;
import flambe.System;

class Bullet extends Component
{
    public function new () { }

    override public function onUpdate (dt)
    {
        var t = owner.get(Transform);
        t.y.set(t.y.get() - dt*0.5);
        if (t.x.get() < 0 || t.x.get() > System.stageWidth ||
            t.y.get() < 0 || t.y.get() > System.stageHeight) {
            owner.dispose();
            return;
        }

        for (enemy in Game.enemies) {
            var et = enemy.get(Transform);
            var dx = t.x.get() - et.x.get();
            var dy = t.y.get() - et.y.get();

            var hull = enemy.get(Hull);
            if (dx*dx + dy*dy < hull.radius*hull.radius) {
                hull.damage(1);

                var exp = new Entity().add(new ExplosionSprite());
                exp.get(Transform).x.set(t.x.get());
                exp.get(Transform).y.set(t.y.get());
                System.root.addChild(exp);

                owner.dispose();
                return;
            }
        }
    }
}
