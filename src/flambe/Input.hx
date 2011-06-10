package flambe;

import flambe.display.MouseEvent;
import flambe.display.Sprite;
import flambe.util.Signal1;

class Input
{
    public static var mouseDown (default, null) :Signal1<MouseEvent>;
    public static var mouseMove (default, null) :Signal1<MouseEvent>;
    public static var mouseUp (default, null) :Signal1<MouseEvent>;

    // TODO: These fields are temporary. While it would be handy to record the mouse state for
    // polling, we want a system that works similarly with touch events too.
    public static var isMouseDown :Bool;
    public static var mouseX :Float;
    public static var mouseY :Float;

    private static function onMouseDown (event :MouseEvent)
    {
        isMouseDown = true;
        mouseX = event.viewX;
        mouseY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.mouseDown.emit(event);
            }
            entity = entity.parent;
        }
    }

    private static function onMouseMove (event :MouseEvent)
    {
        mouseX = event.viewX;
        mouseY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.mouseMove.emit(event);
            }
            entity = entity.parent;
        }
    }

    private static function onMouseUp (event :MouseEvent)
    {
        isMouseDown = false;
        mouseX = event.viewX;
        mouseY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.mouseUp.emit(event);
            }
            entity = entity.parent;
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
            if (sprite != null && !sprite.visible.get()) {
                return false;
            }
            entity = entity.parent;
        }
        return true;
    }

    // Read-only static vars can't be initialized inline
    // http://code.google.com/p/haxe/issues/detail?id=337
    private static function __init__ ()
    {
        mouseDown = new Signal1(onMouseDown);
        mouseMove = new Signal1(onMouseMove);
        mouseUp = new Signal1(onMouseUp);
    }
}
