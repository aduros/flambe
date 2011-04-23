import flambe.Entity;
import flambe.display.ImageSprite;
import flambe.display.Transform;
import flambe.System;

class Main
{
    private static function main ()
    {
        System.init();

        _loader = System.loadAssetPack("bootstrap");
        // Add listeners
        _loader.success.add(onSuccess);
        _loader.error.add(function (message) {
            trace("Load error: " + message);
        });
        _loader.progress.add(function () {
            trace("Loading progress... " + _loader.bytesLoaded + " of " + _loader.bytesTotal);
        });
        // Go!
        _loader.start();
    }

    private static function onSuccess ()
    {
        trace("Loading complete!");

        for (ii in 0...10) {
            var tentacle = new Entity()
                .addComponent(new ImageSprite())
                .addComponent(new Draggable());
            var sprite = tentacle.get(ImageSprite);
            sprite.texture = _loader.pack.createTexture("tentacle.png");
            var xform = tentacle.get(Transform);
            xform.x.set(Math.random() * (System.stageWidth-sprite.getNaturalWidth()));
            xform.y.set(Math.random() * (System.stageHeight-sprite.getNaturalHeight()));
            System.root.addChild(tentacle);
        }
    }

    private static var _loader;
}
