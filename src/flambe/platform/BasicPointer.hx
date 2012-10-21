//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
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
        _id = 0;
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
        _sharedEvent._internal_init(++_id, viewX, viewY, source);
    }

    /**
     * Get the top-most, visible entity that owns a sprite with a mouse signal listener.
     */
    private static function getEntityUnderPoint (x :Float, y :Float) :Entity
    {
        for (sprite in Sprite._internal_interactiveSprites) {
            if (sprite.contains(x, y) && isClickable(sprite.owner)) {
                return sprite.owner;
            }
        }
        return null;
    }

    /**
     * Checks if the entity's sprite, and all its parents' sprites, are clickable.
     */
    private static function isClickable (entity :Entity) :Bool
    {
        while (true) {
            var sprite = entity.get(Sprite);
            if (sprite != null && !sprite.visible) {
                // Ignore invisible sprites
                return false;
            }

            var parent = entity.parent;
            if (parent != null) {
                var director = parent.get(Director);
                if (director != null) {
                    var idx = director.scenes.indexOf(entity);
                    if (idx >= 0 && idx != director.scenes.length-1) {
                        // Ignore scenes that aren't the top scene
                        return false;
                    }
                }
                entity = parent;

            } else {
                break;
            }
        }
        return true;
    }

    private static var _sharedEvent = new PointerEvent();

    private var _id :Int;
    private var _x :Float;
    private var _y :Float;
    private var _isDown :Bool;
}
