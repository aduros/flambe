//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Sprite;
import flambe.input.PointerEvent;
import flambe.math.Point;
import flambe.scene.Director;
import flambe.subsystem.PointerSystem;
import flambe.util.Signal1;

using Lambda;

class BasicPointer
    implements PointerSystem
{
    public var supported (get, null) :Bool;

    public var down (default, null) :Signal1<PointerEvent>;
    public var move (default, null) :Signal1<PointerEvent>;
    public var up (default, null) :Signal1<PointerEvent>;

    public var x (get, null) :Float;
    public var y (get, null) :Float;

    public function new (x :Float = 0, y :Float = 0, isDown :Bool = false)
    {
        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
        _x = x;
        _y = y;
        _isDown = isDown;
    }

    public function get_supported () :Bool
    {
        return true;
    }

    public function get_x () :Float
    {
        return _x;
    }

    public function get_y () :Float
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
        // Ensure a move event is sent first
        submitMove(viewX, viewY, source);
        _isDown = true;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var hit = Sprite.hitTest(System.root, viewX, viewY);
        if (hit != null) {
            var entity = hit.owner;
            do {
                var sprite = entity.get(Sprite);
                if (sprite != null) {
                    chain.push(sprite);
                }
                entity = entity.parent;
            } while (entity != null);
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, hit, source);
        for (sprite in chain) {
            sprite.onPointerDown(_sharedEvent);
            if (_sharedEvent._stopped) {
                return;
            }
        }
        down.emit(_sharedEvent);
    }

    /**
     * Called by the platform to handle a move event.
     */
    public function submitMove (viewX :Float, viewY :Float, source :EventSource)
    {
        if (viewX == _x && viewY == _y) {
            return; // Ignore repeated duplicate move events
        }

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var hit = Sprite.hitTest(System.root, viewX, viewY);
        if (hit != null) {
            var entity = hit.owner;
            do {
                var sprite = entity.get(Sprite);
                if (sprite != null) {
                    chain.push(sprite);
                }
                entity = entity.parent;
            } while (entity != null);
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, hit, source);
        for (sprite in chain) {
            sprite.onPointerMove(_sharedEvent);
            if (_sharedEvent._stopped) {
                return;
            }
        }
        move.emit(_sharedEvent);
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (viewX :Float, viewY :Float, source :EventSource)
    {
        if (!_isDown) {
            return; // Ignore repeat up events
        }
        // Ensure a move event is sent first
        submitMove(viewX, viewY, source);
        _isDown = false;

        // Take a snapshot of the entire event bubbling chain
        var chain = [];
        var hit = Sprite.hitTest(System.root, viewX, viewY);
        if (hit != null) {
            var entity = hit.owner;
            do {
                var sprite = entity.get(Sprite);
                if (sprite != null) {
                    chain.push(sprite);
                }
                entity = entity.parent;
            } while (entity != null);
        }

        // Finally, emit the event up the chain
        prepare(viewX, viewY, hit, source);
        for (sprite in chain) {
            sprite.onPointerUp(_sharedEvent);
            if (_sharedEvent._stopped) {
                return;
            }
        }
        up.emit(_sharedEvent);
    }

    private function prepare (viewX :Float, viewY :Float, hit :Sprite, source :EventSource)
    {
        _x = viewX;
        _y = viewY;
        _sharedEvent.init(_sharedEvent.id+1, viewX, viewY, hit, source);
    }

    private static var _sharedEvent = new PointerEvent();
    private static var _scratchPoint = new Point();

    private var _x :Float;
    private var _y :Float;
    private var _isDown :Bool;
}
