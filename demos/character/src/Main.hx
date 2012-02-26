//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.animation.Easing;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.AnimatedSprite;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.display.SpriteSheet;
import flambe.Entity;
import flambe.math.Point;
import flambe.script.CallFunction;
import flambe.script.MoveTo;
import flambe.script.Parallel;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.System;

class Main
{
    private static function onSuccess (pack :AssetPack)
    {
        var sheet = new SpriteSheet(pack, "avatar");

        var character = new Entity()
            .add(new AnimatedSprite(sheet))
            .add(new Script());
        var sprite = character.get(AnimatedSprite);

        sprite.play("idle");

        // Put it in the middle of the stage
        sprite.setXY(System.stage.width/2, System.stage.height/2);

        System.pointer.down.connect(function (event) {
            // Face left or right
            sprite.scaleX._ = (event.viewX > sprite.x._) ? 1 : -1;

            var vector = new Point(sprite.x._ - event.viewX, sprite.y._ - event.viewY);
            var distance = vector.magnitude();
            var seconds = distance / 200;
            var script = character.get(Script);
            script.stopAll();
            script.run(new Sequence([
                // TODO(bruno): This could be a bit less verbose, something like:
                // MoveTo.linear(event.viewX, event.viewY, seconds),
                new MoveTo(event.viewX, event.viewY, seconds, Easing.linear),
                new CallFunction(function () {
                    character.get(AnimatedSprite).play("idle");
                }),
            ]));
            character.get(AnimatedSprite).play("running");
        });

        var world = new Entity();
        // Add a background
        world.addChild(new Entity().add(
            new FillSprite(0x303030, System.stage.width, System.stage.height)));
        world.addChild(character);
        System.root.addChild(world);
    }

    private static function main ()
    {
        System.init();

        var loader = System.loadAssetPack(Manifest.build("bootstrap"));
        loader.success.connect(onSuccess);
        loader.error.connect(function (message) {
            trace("Load error: " + message);
        });
    }
}
