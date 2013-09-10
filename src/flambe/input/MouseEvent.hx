//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * Represents an event coming from a mouse.
 *
 * _NOTE_: For performance reasons, MouseEvent instances are reused by Flambe. Use `clone()` to
 * retain a reference to an event.
 */
class MouseEvent
{
    /**
     * The X position of the mouse, in view (stage) coordinates.
     */
    public var viewX (default, null) :Float;

    /**
     * The Y position of the mouse, in view (stage) coordinates.
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

    @:allow(flambe) function new ()
    {
        init(0, 0, 0, null);
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :MouseEvent
    {
        var event = new MouseEvent();
        event.init(id, viewX, viewY, button);
        return event;
    }

    @:allow(flambe) function init (id :Int, viewX :Float, viewY :Float, button :MouseButton)
    {
        this.id = id;
        this.viewX = viewX;
        this.viewY = viewY;
        this.button = button;
    }
}
