//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.display.Sprite;

enum EventSource
{
    Mouse (event :MouseEvent);
    Touch (point :TouchPoint);
}

/**
 * Represents an event coming from a pointing device, such as a mouse or finger.
 *
 * _NOTE_: For performance reasons, PointerEvent instances are reused by Flambe. Use `clone()` to
 * retain a reference to an event.
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
     * The deepest sprite lying under the pointer that caused the event, if any. The hit sprite does
     * not necessarily have a pointer event listener connected to it. This event starts at the hit
     * sprite, and propagates upwards to its parents.
     */
    public var hit (default, null) :Sprite;

    /**
     * The source that this event originated from. This can be used to determine if the event came
     * from a mouse or a touch.
     */
    public var source (default, null) :EventSource;

    /**
     * An incrementing ID unique to every dispatched pointer event.
     */
    public var id (default, null) :Int;

    @:allow(flambe) function new ()
    {
        init(0, 0, 0, null, null);
    }

    /**
     * Prevents this PointerEvent from propagating up to parent sprites and the top-level Pointer
     * signal. Other listeners for this event on the current sprite will still fire.
     */
    inline public function stopPropagation ()
    {
        _stopped = true;
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :PointerEvent
    {
        // Ensure the source gets deep copied too
        var sourceCopy = null;
        switch (source) {
            case Mouse(event): sourceCopy = Mouse(event.clone());
            default: sourceCopy = source;
        }

        var event = new PointerEvent();
        event.init(id, viewX, viewY, hit, sourceCopy);
        return event;
    }

    @:allow(flambe) function init (
        id :Int, viewX :Float, viewY :Float, hit :Sprite, source :EventSource)
    {
        this.id = id;
        this.viewX = viewX;
        this.viewY = viewY;
        this.hit = hit;
        this.source = source;
        _stopped = false;
    }

    @:allow(flambe) var _stopped :Bool;
}
