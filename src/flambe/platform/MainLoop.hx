//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Component;
import flambe.Entity;
import flambe.System;
import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.scene.Director;

using Lambda;
using flambe.util.Arrays;
using flambe.util.BitSets;

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

        System.volume.update(dt);

        updateEntity(System.root, dt);
    }

    public function render<A> (renderer :InternalRenderer<A>)
    {
        var graphics = renderer.graphics;
        if (graphics != null) {
            renderer.willRender();
            Sprite.render(System.root, graphics);
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
            speed._realDt = dt;

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
            if (!p._flags.contains(Component.STARTED)) {
                p._flags = p._flags.add(Component.STARTED);
                p.onStart();
            }
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

    private var _tickables :Array<Tickable>;
}
