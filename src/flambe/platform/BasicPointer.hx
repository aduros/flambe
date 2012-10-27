//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Entity;
import flambe.display.Sprite;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
import flambe.math.Point;
import flambe.scene.Director;
import flambe.util.Signal1;

using Lambda;

class BasicPointer
    implements Pointer
{
    public var supported (isSupported, null) :Bool;

    public var down (default, null) :Signal1<PointerEvent>;
    public var move (default, null) :Signal1<PointerEvent>;
    public var up (default, null) :Signal1<PointerEvent>;

    public var x (getX, null) :Float;
    public var y (getY, null) :Float;

    public function new (x :Float = 0, y :Float = 0, isDown :Bool = false)
    {
        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
        _x = x;
        _y = y;
        _isDown = isDown;
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function getX () :Float
    {
        return _x;
    }

    public function getY () :Float
    {
        return _y;
    }

    public function isDown () :Bool
    {
        return _isDown;
    }

    /**
     * Called by the platform to handle a down event.
     */
    public function submitDown (viewX :Float, viewY :Float, source :EventSource)
    {
        if (_isDown) {
            return; // Ignore repeat down events
        }
        _isDown = true;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(viewX, viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                // Avoid calling the public getter and lazily instanciating this signal
                var signal = sprite._internal_pointerDown;
                if (signal != null && signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        if (down.hasListeners()) {
            chain.push(down.clone());
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, source);
        for (signal in chain) {
            signal.emit(_sharedEvent);
            if (_sharedEvent._internal_stopped) {
                break;
            }
        }
    }

    /**
     * Called by the platform to handle a move event.
     */
    public function submitMove (viewX :Float, viewY :Float, source :EventSource)
    {
        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(viewX, viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                // Avoid calling the public getter and lazily instanciating this signal
                var signal = sprite._internal_pointerMove;
                if (signal != null && signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        if (move.hasListeners()) {
            chain.push(move.clone());
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, source);
        for (signal in chain) {
            signal.emit(_sharedEvent);
            if (_sharedEvent._internal_stopped) {
                break;
            }
        }
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (viewX :Float, viewY :Float, source :EventSource)
    {
        if (!_isDown) {
            return; // Ignore repeat up events
        }
        _isDown = false;

        _x = viewX;
        _y = viewY;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(viewX, viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                // Avoid calling the public getter and lazily instanciating this signal
                var signal = sprite._internal_pointerUp;
                if (signal != null && signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        if (up.hasListeners()) {
            chain.push(up.clone());
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, source);
        for (signal in chain) {
            signal.emit(_sharedEvent);
            if (_sharedEvent._internal_stopped) {
                break;
            }
        }
    }

    private function prepare (viewX :Float, viewY :Float, source :EventSource)
    {
        _x = viewX;
        _y = viewY;
        _sharedEvent._internal_init(_sharedEvent.id+1, viewX, viewY, source);
    }

    /**
     * Get the top-most, visible entity that owns a sprite with a mouse signal listener.
     */
    private static function getEntityUnderPoint (x :Float, y :Float) :Entity
    {
        return hitTest(System.root, x, y);
    }

    private static function hitTest (entity :Entity, x :Float, y :Float) :Entity
    {
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            if (!sprite.visible) {
                return null; // Prune invisible sprites
            }
            if (sprite.getLocalMatrix().inverseTransform(x, y, _scratchPoint)) {
                x = _scratchPoint.x;
                y = _scratchPoint.y;
            }
        }

        // Hit test all children, front to back
        var children = entity._internal_children;
        var ii = children.length - 1;
        while (ii >= 0) {
            var child = children[ii];
            if (child != null) {
                var result = hitTest(child, x, y);
                if (result != null) {
                    return result;
                }
            }
            --ii;
        }

        // Hit test the top director scene, if any
        var director = entity.get(Director);
        if (director != null) {
            var topScene = director.topScene;
            if (topScene != null) {
                var result = hitTest(topScene, x, y);
                if (result != null) {
                    return result;
                }
            }
        }

        // Finally, if we got this far, hit test the actual sprite
        return (sprite != null && sprite.containsLocal(x, y)) ? entity : null;
    }

    private static var _sharedEvent = new PointerEvent();
    private static var _scratchPoint = new Point();

    private var _x :Float;
    private var _y :Float;
    private var _isDown :Bool;
}
