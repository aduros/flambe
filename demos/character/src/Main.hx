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
import flambe.display.Transform;
import flambe.Entity;
import flambe.Input;
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

        character.get(AnimatedSprite).play("idle");

        // Put it in the middle of the stage
        var transform = character.get(Transform);
        transform.x._ = System.stage.width/2;
        transform.y._ = System.stage.height/2;

        Input.mouseDown.connect(function (event) {
            // Face left or right
            var transform = character.get(Transform);
            transform.scaleX._ = (event.viewX > transform.x._) ? 1 : -1;

            var delay = flambe.math.FMath.toInt(5*transform.distanceTo(event.viewX, event.viewY));
            var script = character.get(Script);
            script.stopAll();
            script.run(new Sequence([
                // TODO: This could be a bit less verbose, something like:
                // MoveTo.linear(event.viewX, event.viewY, delay),
                new MoveTo(event.viewX, event.viewY, delay, Easing.linear),
                new CallFunction(function () {
                    character.get(AnimatedSprite).play("idle");
                }),
            ]));
            character.get(AnimatedSprite).play("running");
        });

        var world = new Entity().add(new Sprite()); // TODO: Requiring new Sprite() here is quirky
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
