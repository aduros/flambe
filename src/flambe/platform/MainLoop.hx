//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Component;
import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.scene.Director;
import flambe.System;

using Lambda;

/**
 * Updates all components and renders.
 */
class MainLoop
{
    public function new ()
    {
        _tickables = [];
    }

    public function update (dt :Float)
    {
        if (dt <= 0) {
            // This can happen on platforms that don't have monotonic timestamps and are prone to
            // system clock adjustment
            Log.warn("Zero or negative time elapsed since the last frame!", ["dt", dt]);
            return;
        }
        if (dt > 1) {
            // Clamp deltaTime to a reasonable limit. Games tend not to cope well with huge
            // deltaTimes. Platforms should skip the next frame after unpausing to prevent sending
            // huge deltaTimes, but not all environments support detecting an unpause
            dt = 1;
        }

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

        updateEntity(System.root, dt);
    }

    public function render (renderer :Renderer)
    {
        var graphics = renderer.willRender();
        if (graphics != null) {
            renderEntity(System.root, graphics);
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

    private static function updateEntity (entity :Entity, dt :Float)
    {
        // Handle update speed adjustment
        var speed = entity.get(SpeedAdjuster);
        if (speed != null) {
            speed._internal_realDt = dt;

            dt *= speed.scale._;
            if (dt <= 0) {
                // This entity is paused, avoid descending into children. But do update the speed
                // adjuster (so it can still be animated)
                speed.onUpdate(dt);
                return;
            }
        }

        // Update components
        var p = entity.firstComponent;
        while (p != null) {
            var next = p.next;
            p.onUpdate(dt);
            p = next;
        }

        // Update children
        var p = entity.firstChild;
        while (p != null) {
            var next = p.next;
            updateEntity(p, dt);
            p = next;
        }
    }

    private static function renderEntity (entity :Entity, g :Graphics)
    {
        // Render this child's sprite
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            var alpha = sprite.alpha._;
            if (!sprite.visible || alpha <= 0) {
                return; // Prune traversal, this sprite and all children are invisible
            }

            g.save();
            if (alpha < 1) {
                g.multiplyAlpha(alpha);
            }
            if (sprite.blendMode != null) {
                g.setBlendMode(sprite.blendMode);
            }
            var matrix = sprite.getLocalMatrix();
            g.transform(matrix.m00, matrix.m10, matrix.m01, matrix.m11, matrix.m02, matrix.m12);

            sprite.draw(g);
        }

        // Render any partially occluded director scenes
        var director = entity.get(Director);
        if (director != null) {
            var scenes = director.occludedScenes;
            for (scene in scenes) {
                renderEntity(scene, g);
            }
        }

        // Render all children
        var p = entity.firstChild;
        while (p != null) {
            var next = p.next;
            renderEntity(p, g);
            p = next;
        }

        // If save() was called, unwind it
        if (sprite != null) {
            g.restore();
        }
    }

    private var _tickables :Array<Tickable>;
}
