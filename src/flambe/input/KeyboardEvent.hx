//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * Represents an event coming from a physical key press. NOTE: For performance reasons,
 * KeyboardEvent instances are reused by Flambe. Use clone() to retain a reference to an event.
 */
class KeyboardEvent
{
    /**
     * The key that caused this event.
     */
    public var key (default, null) :Key;

    /**
     * An incrementing ID unique to every dispatched key event.
     */
    public var id (default, null) :Int;

    /** @private */ public function new ()
    {
        _internal_init(0, null);
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :KeyboardEvent
    {
        var event = new KeyboardEvent();
        event._internal_init(id, key);
        return event;
    }

    /** @private */ public function _internal_init (id :Int, key :Key)
    {
        this.id = id;
        this.key = key;
    }
}
