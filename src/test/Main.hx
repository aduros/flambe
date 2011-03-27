package test;

import flambe.animation.Property;
import flambe.Entity;
import flambe.LogVisitor;
import flambe.Component;
import flambe.Visitor;
import flambe.System;

using flambe.display.Transform;
using flambe.display.Sprite;
using flambe.display.ImageSprite;

#if amity
import js.Boot; // FIXME: --dead-code-elimination seems to require this. Bug?
#end

class Main
{
    public static function main ()
    {
        System.init();

        var loader = System.loadAssetPack("bootstrap");
        loader.success.add(function () {
            var dude = new Entity().withImageSprite();
            dude.getImageSprite().texture = loader.pack.createTexture("subdir/man.png");
            System.mouseDown.add(function (event) {
                var xform = dude.getTransform();
                xform.x.animateTo(event.viewX, 1000);
                xform.y.animateTo(event.viewY, 1000);
                // TODO: animateBy
                xform.rotation.animateTo(dude.getTransform().rotation.get() + 360, 1000);
            });
            System.root.addChild(dude);
        });
        loader.error.add(function (text) {
            trace("Error :( " + text);
        });
        loader.progress.add(function () {
            trace("Loading progress: " + loader.bytesLoaded + " of " + loader.bytesTotal);
        });
        loader.start();
    }
}
