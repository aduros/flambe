//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.Component;
import flambe.display.AnimatedSprite;
import flambe.display.Sprite;
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
        var sprite = owner.get(Sprite);
        sprite.y._ -= dt*0.5;
        if (sprite.x._ < 0 || sprite.x._ > System.stage.width ||
            sprite.y._ < 0 || sprite.y._ > System.stage.height) {
            owner.dispose();
            return;
        }

        for (enemy in Game.enemies) {
            var enemySprite = enemy.get(Sprite);
            var dx = sprite.x._ - enemySprite.x._;
            var dy = sprite.y._ - enemySprite.y._;

            var hull = enemy.get(Hull);
            if (dx*dx + dy*dy < hull.radius*hull.radius) {
                hull.damage(1);

                // FIXME: Migrate to new AnimatedSprite system
                // var fireball = new Entity()
                //     .add(new AnimatedSprite(ShooterCtx.pack.loadTexture("explosion.png"), 13, 1))
                //     .add(new Script());
                // fireball.get(AnimatedSprite).centerAnchor();
                // fireball.get(Script).run(new Sequence([
                //     new Delay(0.001*EXPLOSION.delay*EXPLOSION.frames.length), // TODO(bruno): WaitForFrame
                //     new CallFunction(fireball.dispose),
                // ]));
                // fireball.get(AnimatedSprite).play(EXPLOSION);
                // fireball.get(Transform).x._ = t.x._;
                // fireball.get(Transform).y._ = t.y._;
                // fireball.get(AnimatedSprite).blendMode = Add;
                // System.root.addChild(fireball);

                owner.dispose();
                return;
            }
        }
    }
}
