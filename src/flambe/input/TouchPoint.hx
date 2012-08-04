//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.input.PointerEvent;

/**
 * Represents a touch screen contact point, such as a finger. It is possible to retain a reference
 * to a TouchPoint, and track changes to it over time.
 */
class TouchPoint
{
    /**
     * The X position of the touch, in view (stage) coordinates. This value is modified when the
     * point moves.
     */
    public var viewX (default, null) :Float;

    /**
     * The Y position of the touch, in view (stage) coordinates. This value is modified when the
     * point moves.
     */
    public var viewY (default, null) :Float;

    /**
     * An identifier unique to this touch.
     */
    public var id (default, null) :Int;

    /** @private */ public function new (id :Int)
    {
        this.id = id;
        _internal_source = Touch(this);
    }

    /** @private */ public function _internal_init (viewX :Float, viewY :Float)
    {
        this.viewX = viewX;
        this.viewY = viewY;
    }

    // Cached to avoid lots of allocation
    /** @private */ public var _internal_source :EventSource;
}
