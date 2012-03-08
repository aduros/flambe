//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Component;
import flambe.display.DrawingContext;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.scene.Director;
import flambe.System;
import flambe.Visitor;

using Lambda;

/**
 * Updates all components and renders.
 */
class MainLoop
{
    public function new ()
    {
        _updateVisitor = new UpdateVisitor();
        _drawVisitor = new DrawVisitor();
        _tickables = [];
    }

    public function update (dt :Int)
    {
        // First update any tickables, folding away nulls
        var ii = 0;
        while (ii < _tickables.length) {
            var t = _tickables[ii];
            if (t == null || t.update(dt)) {
                _tickables.splice(ii, 1);
            } else {
                ++ii;
            }
        }

        // Then update the entity hierarchy
        _updateVisitor.dt = dt;
        System.root.visit(_updateVisitor, true, true);
    }

    public function render (renderer :Renderer)
    {
        var drawCtx = renderer.willRender();
        if (drawCtx != null) {
            _drawVisitor.drawCtx = drawCtx;
            System.root.visit(_drawVisitor, false, true);
            renderer.didRender();
        }
    }

    public function addTickable (t :Tickable)
    {
        _tickables.push(t);
    }

    public function removeTickable (t :Tickable)
    {
        var idx = _tickables.indexOf(t);
        if (idx >= 0) {
            // Actual removals only happen in update()
            _tickables[idx] = null;
        }
    }

    private var _updateVisitor :UpdateVisitor;
    private var _drawVisitor :DrawVisitor;

    private var _tickables :Array<Tickable>;
}

private class UpdateVisitor
    implements Visitor
{
    public var dt :Int;

    public function new ()
    {
    }

    public function enterEntity (entity :Entity) :Bool
    {
        return true;
    }

    public function leaveEntity (entity :Entity)
    {
    }

    public function acceptComponent (component :Component)
    {
        component.onUpdate(dt);
    }
}

private class DrawVisitor
    implements Visitor
{
    public var drawCtx :DrawingContext;

    public function new ()
    {
    }

    public function enterEntity (entity :Entity) :Bool
    {
        var director = entity.get(Director);
        if (director != null) {
            for (scene in director.visibleScenes) {
                scene.visit(this, false, true);
            }
        }

        var sprite = entity.get(Sprite);
        if (sprite == null) {
            return true;
        }

        var alpha = sprite.alpha._;
        if (!sprite.visible._ || alpha <= 0) {
            return false;
        }

        drawCtx.save();

        if (alpha < 1) {
            drawCtx.multiplyAlpha(alpha);
        }

        if (sprite.blendMode != null) {
            drawCtx.setBlendMode(sprite.blendMode);
        }

        var x = sprite.x._;
        var y = sprite.y._;
        if (x != 0 || y != 0) {
            drawCtx.translate(x, y);
        }

        var rotation = sprite.rotation._;
        if (rotation != 0) {
            drawCtx.rotate(rotation);
        }

        var scaleX = sprite.scaleX._;
        var scaleY = sprite.scaleY._;
        if (scaleX != 1 || scaleY != 1) {
            drawCtx.scale(scaleX, scaleY);
        }

        var anchorX = sprite.anchorX._;
        var anchorY = sprite.anchorY._;
        if (anchorX != 0 || anchorY != 0) {
            drawCtx.translate(-anchorX, -anchorY);
        }

        sprite.draw(drawCtx);

        return true;
    }

    public function leaveEntity (entity :Entity)
    {
        if (entity.has(Sprite)) {
            drawCtx.restore();
        }
    }

    public function acceptComponent (component :Component)
    {
    }
}
