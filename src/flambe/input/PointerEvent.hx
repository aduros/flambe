//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * Represents an event coming from a pointing device, such as a mouse or finger. NOTE: For
 * performance reasons, PointerEvent instances are reused by Flambe. Use clone() to retain a
 * reference to an event.
 */
class PointerEvent
{
    /**
     * The X position of the pointing device, in view (stage) coordinates.
     */
    public var viewX (default, null) :Float;

    /**
     * The Y position of the pointing device, in view (stage) coordinates.
     */
    public var viewY (default, null) :Float;

    /**
     * An incrementing ID unique to every dispatched pointer event.
     */
    public var id (default, null) :Int;

    /** @private */ public function new ()
    {
    }

    public function clone () :PointerEvent
    {
        var event = new PointerEvent();
        event._internal_init(id, viewX, viewY);
        return event;
    }

    /** @private */ public function _internal_init (id :Int, viewX :Float, viewY :Float)
    {
        this.id = id;
        this.viewX = viewX;
        this.viewY = viewY;
    }
}
