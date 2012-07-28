//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

enum EventSource
{
    Mouse (event :MouseEvent);
    Touch;
}

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
     * The source that this event originated from. This can be used to determine if the event came
     * from a mouse or a touch.
     */
    public var source (default, null) :EventSource;

    /**
     * An incrementing ID unique to every dispatched pointer event.
     */
    public var id (default, null) :Int;

    /** @private */ public function new ()
    {
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :PointerEvent
    {
        // Ensure the source gets deep copied too
        var sourceCopy = null;
        switch (sourceCopy) {
            case Mouse(event): sourceCopy = Mouse(event.clone());
            case Touch: sourceCopy = Touch;
        }

        var event = new PointerEvent();
        event._internal_init(id, viewX, viewY, sourceCopy);
        return event;
    }

    /** @private */ public function _internal_init (
        id :Int, viewX :Float, viewY :Float, source :EventSource)
    {
        this.id = id;
        this.viewX = viewX;
        this.viewY = viewY;
        this.source = source;
    }
}
