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

        trace("Launching app!");
        var test = new Entity().withImageSprite();
        trace(test.getImageSprite().getName());

        for (ii in 0...20) {
            var entity = new Entity();
            var sprite = entity.requireImageSprite();
            entity.getTransform().x.animateTo(Math.random()*200, 5000);
            entity.getTransform().y.animateTo(Math.random()*200, 5000);
            entity.getTransform().rotation.animateTo(360*Math.random()*4, 5000);

            var other = new Entity();
            var sprite = other.requireSprite();
            other.getTransform().x.bindTo(entity.getTransform().x);
            System.root.addChild(entity);
            System.root.addChild(other);
        }

	var spinner = new Entity().withImageSprite();
        var transform = spinner.getTransform();
	transform.x.set(50);
	transform.y.set(80);
        transform.rotation.animateTo(10*360, 300000);

	var test = new Entity().withImageSprite();
        test.getTransform().x.set(100);
        test.getImageSprite().mouseDown.add(function (_) trace("Clicky"));
	spinner.addChild(test);
        System.root.addChild(spinner);
    }
}
