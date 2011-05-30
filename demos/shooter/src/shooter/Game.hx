package shooter;

import flambe.animation.Easing;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.Sprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.Input;
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
            .add(new PatternSprite(ShooterCtx.pack.createTexture("water.png")))
            .add(new WaterScroller(0.1/4));
        water.get(PatternSprite).width.set(System.stageWidth);
        water.get(PatternSprite).height.set(System.stageHeight+32);
        water.get(Transform).y.set(-32);
        owner.addChild(water);

        var cloudLayer = new Entity().add(new Sprite()).add(new Script());
        cloudLayer.get(Script).run(new Repeat(new Sequence([
            new Delay(4*0.8),
            new CallFunction(function () {
                var texture = ShooterCtx.pack.createTexture("cloud.png");
                var cloud = new Entity().add(new ImageSprite(texture));
                var t = cloud.get(Transform);
                t.x.set(Math.random()*(System.stageWidth+texture.width) - texture.width);
                t.y.set(-texture.height);
                cloud.get(Sprite).alpha.set(0.8);
                cloudLayer.get(Script).run(new Sequence([
                    new AnimateTo(cloud.get(Transform).y, System.stageHeight, 3*Std.int(8000+2000*Math.random()), Easing.linear),
                    new CallFunction(cloud.dispose)
                ]));
                cloudLayer.addChild(cloud);
            }),
        ])));
        owner.addChild(cloudLayer);

        player = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.createTexture("player.png")))
            .add(new Script());
        var sprite = player.get(ImageSprite);
        sprite.centerAnchor();
        player.get(Script).run(new Repeat(new Sequence([
           new Delay(0.2),
           new CallFunction(function () {
               var bullet = new Entity()
                   .add(new ImageSprite(ShooterCtx.pack.createTexture("bullet.png")))
                   .add(new Bullet());
               bullet.get(Sprite).centerAnchor();
               bullet.get(Transform).x.set(player.get(Transform).x.get());
               bullet.get(Transform).y.set(player.get(Transform).y.get());
               flambe.System.root.addChild(bullet);
           }),
        ])));

        Input.mouseMove.connect(function (event) {
            if (player == null) {
                return;
            }
            var t = player.get(Transform);
            t.x.set(event.viewX);
            t.y.set(event.viewY-100);
        });
        owner.addChild(player);

        var enemySpawner = new Entity().add(new Script());
        enemySpawner.get(Script).run(new Repeat(new Sequence([
            new Delay(1),
            new CallFunction(function () {
                var enemy = Math.random() > 0.5 ? buildBomber() : buildSwarmer();
                enemies.push(enemy);
                enemySpawner.parent.addChild(enemy);
            }),
        ])));
        owner.addChild(enemySpawner);
    }

    public static function buildSwarmer () :Entity
    {
        var enemy = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.createTexture("enemy0.png")))
            .add(new Hull(20, 1))
            .add(new SwarmerAI());
        enemy.get(Sprite).centerAnchor();
        return enemy;
    }

    public static function buildBomber () :Entity
    {
        var enemy = new Entity()
            .add(new ImageSprite(ShooterCtx.pack.createTexture("enemy1.png")))
            .add(new Hull(40, 5))
            .add(new BomberAI());
        enemy.get(Sprite).centerAnchor();
        enemy.get(Transform).x.set(Math.random()*flambe.System.stageWidth);
        enemy.get(Transform).y.set(-enemy.get(Sprite).getNaturalHeight()/2);
        return enemy;
    }

    public static var enemies :Array<Entity>;
    public static var player :Entity;
}
