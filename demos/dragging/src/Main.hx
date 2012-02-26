//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.System;

class Main
{
    private static function main ()
    {
        var loader = System.loadAssetPack(Manifest.build("bootstrap"));
        // Add listeners
        loader.success.connect(onSuccess);
        loader.error.connect(function (message) {
            trace("Load error: " + message);
        });
        loader.progressChanged.connect(function () {
            trace("Loading progress... " + loader.progress + " of " + loader.total);
        });
    }

    private static function onSuccess (pack :AssetPack)
    {
        trace("Loading complete!");

        // Add a filled background color
        System.root.addChild(new Entity()
            .add(new FillSprite(0x303030, System.stage.width, System.stage.height)));

        for (ii in 0...10) {
            var tentacle = new Entity()
                .add(new ImageSprite(pack.loadTexture("tentacle.png")))
                .add(new Draggable());
            var sprite = tentacle.get(ImageSprite);
            sprite.x._ = Math.random() * (System.stage.width-sprite.getNaturalWidth());
            sprite.y._ = Math.random() * (System.stage.height-sprite.getNaturalHeight());
            sprite.scaleX._ = sprite.scaleY._ = 0.5 + Math.random()*4;
            sprite.rotation._ = Math.random()*90;
            System.root.addChild(tentacle);
        }
    }
}
