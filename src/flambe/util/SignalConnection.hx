//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Represents a connected signal listener.
 */
class SignalConnection
    implements Disposable
{
    /**
     * True if the listener will remain connected after being used.
     */
    public var stayInList (default, null) :Bool;

    /** @private */
    public function new (signal :SignalBase, listener :Dynamic)
    {
        _signal = signal;
        _internal_listener = listener;
        stayInList = true;
    }

    /**
     * Tells the connection to dispose itself after being used once.
     * @returns This instance, for chaining.
     */
    public function once ()
    {
        stayInList = false;
        return this;
    }

    /**
     * Disconnects the listener from the signal.
     */
    public function dispose ()
    {
        if (_signal != null) {
            _signal._internal_disconnect(this);
            _signal = null;
        }
    }

    /** @private */ public var _internal_next :SignalConnection = null;

    /** @private */ public var _internal_listener :Dynamic;
    private var _signal :SignalBase;
}
