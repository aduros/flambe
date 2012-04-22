//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.Pointer;
import flambe.input.PointerEvent;
import flambe.util.Signal1;

class BasicPointer
    implements Pointer
{
    public var supported (isSupported, null) :Bool;

    public var down (default, null) :Signal1<PointerEvent>;
    public var move (default, null) :Signal1<PointerEvent>;
    public var up (default, null) :Signal1<PointerEvent>;

    public var x (getX, null) :Float;
    public var y (getY, null) :Float;

    public function new (x :Int = 0, y :Int = 0, isDown :Bool = false)
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
    public function submitDown (event :PointerEvent)
    {
        if (_isDown) {
            return; // Ignore repeat down events
        }

        _isDown = true;
        _x = event.viewX;
        _y = event.viewY;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                var signal = sprite.pointerDown;
                if (signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        chain.push(down.clone());

        // Finally, emit the event up the chain
        for (signal in chain) {
            signal.emit(event);
        }
    }

    /**
     * Called by the platform to handle a move event.
     */
    public function submitMove (event :PointerEvent)
    {
        _x = event.viewX;
        _y = event.viewY;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                var signal = sprite.pointerMove;
                if (signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        chain.push(move.clone());

        // Finally, emit the event up the chain
        for (signal in chain) {
            signal.emit(event);
        }
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (event :PointerEvent)
    {
        if (!_isDown) {
            return; // Ignore repeat up events
        }

        _isDown = false;
        _x = event.viewX;
        _y = event.viewY;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                var signal = sprite.pointerUp;
                if (signal.hasListeners()) {
                    chain.push(signal.clone());
                }
            }
            entity = entity.parent;
        }
        chain.push(up.clone());

        // Finally, emit the event up the chain
        for (signal in chain) {
            signal.emit(event);
        }
    }

    /**
     * Get the top-most, visible entity that owns a sprite with a mouse signal listener.
     */
    private static function getEntityUnderPoint (x :Float, y :Float) :Entity
    {
        for (sprite in Sprite._internal_interactiveSprites) {
            if (sprite.contains(x, y) && isVisible(sprite.owner)) {
                return sprite.owner;
            }
        }
        return null;
    }

    /**
     * Checks if the entity's sprite, and all its parents' sprites, are visible.
     */
    private static function isVisible (entity :Entity) :Bool
    {
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null && !sprite.visible._) {
                return false;
            }
            entity = entity.parent;
        }
        return true;
    }

    private var _x :Float;
    private var _y :Float;
    private var _isDown :Bool;
}
