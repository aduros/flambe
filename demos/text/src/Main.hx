//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.animation.Easing;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.System;

class Main
{
    public static function onSuccess (pack :AssetPack)
    {
        var bg = new Entity().add(new FillSprite(0xffffff, System.stage.width, System.stage.height));
        System.root.addChild(bg);

        var font = new Font(pack, "myfont");
        var label = new Entity()
            .add(new TextSprite(font, "Go ahead, tap me"));

        var messages = [
            "You call that a tap?",
            "Ouch :(",
            "Missed me...",
            "(Your touch screen works)",
        ];
        var taps = 0;
        var sprite = label.get(TextSprite);
        sprite.pointerDown.connect(function (_) {
            var margin = 50;
            sprite.x.animateTo(
                margin + (System.stage.width - 2*margin)*Math.random(), 1, Easing.linear);
            sprite.y.animateTo(
                margin + (System.stage.height - 2*margin)*Math.random(), 1, Easing.linear);
            sprite.rotation.animateTo(360*Math.random(), 1, Easing.quadOut);
            sprite.text = messages[taps++ % messages.length];
        });

        System.root.addChild(label);
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
