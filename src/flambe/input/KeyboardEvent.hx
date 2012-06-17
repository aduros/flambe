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
     * The key's character code. This value is platform dependent, so be sure to test thoroughly,
     * especially across different browsers in the HTML target: http://unixpapa.com/js/key.html
     */
    public var charCode (default, null) :Int;

    /**
     * An incrementing ID unique to every dispatched key event.
     */
    public var id (default, null) :Int;

    /** @private */ public function new ()
    {
    }

    /**
     * Creates a copy of this event.
     */
    public function clone () :KeyboardEvent
    {
        var event = new KeyboardEvent();
        event._internal_init(id, charCode);
        return event;
    }

    /** @private */ public function _internal_init (id :Int, charCode :Int)
    {
        this.id = id;
        this.charCode = charCode;
    }
}
