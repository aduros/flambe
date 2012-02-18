//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.animation.Easing;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.System;

import shooter.BomberAI;
import shooter.SwarmerAI;
import shooter.Bullet;

// TODO(bruno): Having all-encompassing game logic in a component is kind of strange. Once Flambe
// gets scene/mode management, this should live in there.
class Game extends Component
{
    public function new ()
    {
        enemies = [];
    }

    override public function onAdded ()
    {
        var water = new Entity()
            .add(new PatternSprite(ShooterCtx.pack.loadTexture("water.png")))
            .add(new WaterScroller(0.1/4));
        var sprite = water.get(PatternSprite);
        sprite.width._ = System.stage.width;
        sprite.height._ = System.stage.height+32;
        sprite.y._ = -32;
        owner.addChild(water);

        var cloudLayer = new Entity().add(new Sprite()).add(new Script());
        cloudLayer.get(Script).run(new Repeat(new Sequence([
            new Delay(4*0.8),
            new CallFunction(function () {
                var texture = ShooterCtx.pack.loadTexture("cloud.png");
                var cloud = new Entity().add(new ImageSprite(texture));
                var sprite = cloud.get(Sprite);
                sprite.x._ = Math.random()*(System.stage.width+texture.width) - texture.width;
                sprite.y._ = -texture.height;
                sprite.alpha._ = 0.8;
                cloudLayer.get(Script).run(new Sequence([
                    new AnimateTo(sprite.y, System.stage.height,
                        3*(8+2*Math.random()), Easing.linear),
                    new CallFunction(cloud.dispose)
                ]));
                cloudLayer.addChild(cloud);
            }),
        ])));
        owner.addChild(cloudLayer);

        player = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.loadTexture("player.png")))
            .add(new Script());
        var sprite = player.get(ImageSprite);
        sprite.centerAnchor();
        player.get(Script).run(new Repeat(new Sequence([
           new Delay(0.2),
           new CallFunction(function () {
               var bullet = new Entity()
                   .add(new ImageSprite(ShooterCtx.pack.loadTexture("bullet.png")))
                   .add(new Bullet());
               var sprite = bullet.get(Sprite);
               sprite.centerAnchor();
               sprite.x._ = player.get(Sprite).x._;
               sprite.y._ = player.get(Sprite).y._;
               flambe.System.root.addChild(bullet);
           }),
        ])));

        System.pointer.move.connect(function (event) {
            if (player == null) {
                return;
            }
            var sprite = player.get(Sprite);
            sprite.x._ = event.viewX;
            sprite.y._ = event.viewY-50;
        });
        owner.addChild(player);

        var enemySpawner = new Entity().add(new Script());
        enemySpawner.get(Script).run(new Repeat(new Sequence([
            new Delay(1),
            new CallFunction(function () {
                var enemy = Math.random() > 0.5 ? buildBomber() : buildSwarmer();
                enemies.push(enemy);
                owner.addChild(enemy);
            }),
        ])));
        owner.addChild(enemySpawner);
    }

    public static function buildSwarmer () :Entity
    {
        var enemy = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.loadTexture("enemy0.png")))
            .add(new Hull(20, 1))
            .add(new SwarmerAI());
        var sprite = enemy.get(Sprite);
        sprite.centerAnchor();
        sprite.alpha.animate(0, 1, 2);
        sprite.scaleX.animate(0, 1, 2);
        sprite.scaleY.animate(0, 1, 2);
        return enemy;
    }

    public static function buildBomber () :Entity
    {
        var enemy = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.loadTexture("enemy1.png")))
            .add(new Hull(40, 5))
            .add(new BomberAI());
        var sprite = enemy.get(Sprite);
        sprite.centerAnchor();
        sprite.x._ = Math.random()*System.stage.width;
        sprite.y._ = -sprite.getNaturalHeight()/2;
        return enemy;
    }

    public static var enemies :Array<Entity>;
    public static var player :Entity;
}
