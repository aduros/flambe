import flambe.Entity;
import flambe.System;

using flambe.display.ImageSprite;
using flambe.display.Transform;
using Draggable;

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
            var tentacle = new Entity().withImageSprite().withDraggable();
            var sprite = tentacle.getImageSprite();
            sprite.texture = _loader.pack.createTexture("tentacle.png");
            var xform = tentacle.getTransform();
            xform.x.set(Math.random() * (System.stageWidth-sprite.getNaturalWidth()));
            xform.y.set(Math.random() * (System.stageHeight-sprite.getNaturalHeight()));
            System.root.addChild(tentacle);
        }
    }

    private static var _loader;
}
