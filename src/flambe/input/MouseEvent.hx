//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * Represents an event coming from a mouse. NOTE: For performance reasons, MouseEvent instances are
 * reused by Flambe. Use clone() to retain a reference to an event.
 */
class MouseEvent
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
     * The mouse button that caused this event, or null for movement events.
     */
    public var button (default, null) :MouseButton;

    /**
     * An incrementing ID unique to every dispatched mouse event.
     */
    public var id (default, null) :Int;

    /** @private */ public function new ()
    {
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :MouseEvent
    {
        var event = new MouseEvent();
        event._internal_init(id, viewX, viewY, button);
        return event;
    }

    /** @private */ public function _internal_init (
        id :Int, viewX :Float, viewY :Float, button :MouseButton)
    {
        this.id = id;
        this.viewX = viewX;
        this.viewY = viewY;
        this.button = button;
    }
}
