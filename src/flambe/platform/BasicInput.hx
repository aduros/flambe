//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.Input;
import flambe.input.KeyEvent;
import flambe.input.PointerEvent;
import flambe.util.Signal1;

class BasicInput
    implements Input
{
    public var pointerDown (default, null) :Signal1<PointerEvent>;
    public var pointerMove (default, null) :Signal1<PointerEvent>;
    public var pointerUp (default, null) :Signal1<PointerEvent>;

    public var pointerX (default, null) :Float;
    public var pointerY (default, null) :Float;

    public var keyDown (default, null) :Signal1<KeyEvent>;
    public var keyUp (default, null) :Signal1<KeyEvent>;

    public function new ()
    {
        pointerDown = new Signal1(onPointerDown);
        pointerMove = new Signal1(onPointerMove);
        pointerUp = new Signal1(onPointerUp);
        keyDown = new Signal1(onKeyDown);
        keyUp = new Signal1(onKeyUp);
        _pointerDown = false;
        _keyStates = new IntHash();
    }

    public function isPointerDown () :Bool
    {
        return _pointerDown;
    }

    public function isKeyDown (charCode :Int) :Bool
    {
        return _keyStates.exists(charCode);
    }

    private function onPointerDown (event :PointerEvent)
    {
        _pointerDown = true;
        pointerX = event.viewX;
        pointerY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.pointerDown.emit(event);
            }
            entity = entity.parent;
        }
    }

    private function onPointerMove (event :PointerEvent)
    {
        pointerX = event.viewX;
        pointerY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.pointerMove.emit(event);
            }
            entity = entity.parent;
        }
    }

    private function onPointerUp (event :PointerEvent)
    {
        _pointerDown = false;
        pointerX = event.viewX;
        pointerY = event.viewY;

        var entity = getEntityUnderPoint(event.viewX, event.viewY);
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                sprite.pointerUp.emit(event);
            }
            entity = entity.parent;
        }
    }

    private function onKeyDown (event :KeyEvent)
    {
        _keyStates.set(event.charCode, true);
    }

    private function onKeyUp (event :KeyEvent)
    {
        _keyStates.remove(event.charCode);
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

    private var _pointerDown :Bool;
    private var _keyStates :IntHash<Bool>;
}
