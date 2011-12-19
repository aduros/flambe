//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.System;

class Main
{
    private static function main ()
    {
        System.init();

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
            var xform = tentacle.get(Transform);
            xform.x._ = Math.random() * (System.stage.width-sprite.getNaturalWidth());
            xform.y._ = Math.random() * (System.stage.height-sprite.getNaturalHeight());
            xform.scaleX._ = xform.scaleY._ = 0.5 + Math.random()*4;
            xform.rotation._ = Math.random()*90;
            System.root.addChild(tentacle);
        }
    }

}
