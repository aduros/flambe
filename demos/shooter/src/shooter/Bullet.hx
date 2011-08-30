//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.Component;
import flambe.display.AnimatedSprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.System;

class Bullet extends Component
{
    public function new () { }

    override public function onUpdate (dt)
    {
        var t = owner.get(Transform);
        t.y._ -= dt*0.5;
        if (t.x._ < 0 || t.x._ > System.stageWidth ||
            t.y._ < 0 || t.y._ > System.stageHeight) {
            owner.dispose();
            return;
        }

        for (enemy in Game.enemies) {
            var et = enemy.get(Transform);
            var dx = t.x._ - et.x._;
            var dy = t.y._ - et.y._;

            var hull = enemy.get(Hull);
            if (dx*dx + dy*dy < hull.radius*hull.radius) {
                hull.damage(1);

                var fireball = new Entity()
                    .add(new AnimatedSprite(ShooterCtx.pack.loadTexture("explosion.png"), 13, 1))
                    .add(new Script());
                fireball.get(AnimatedSprite).centerAnchor();
                fireball.get(Script).run(new Sequence([
                    new Delay(0.001*EXPLOSION.delay*EXPLOSION.frames.length), // TODO(bruno): WaitForFrame
                    new CallFunction(fireball.dispose),
                ]));
                fireball.get(AnimatedSprite).play(EXPLOSION);
                fireball.get(Transform).x._ = t.x._;
                fireball.get(Transform).y._ = t.y._;
                // fireball.get(AnimatedSprite).blendMode = Add;
                System.root.addChild(fireball);

                owner.dispose();
                return;
            }
        }
    }

    public static var EXPLOSION = new Animation(50, [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ]);
}
