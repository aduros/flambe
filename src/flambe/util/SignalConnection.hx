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
    public function new (signal :SignalImpl, listener :Dynamic)
    {
        _internal_signal = signal;
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
        if (_internal_signal != null) {
            _internal_signal.disconnect(this);
        }
    }

    /** @private */ public var _internal_listener :Dynamic;
    /** @private */ public var _internal_signal :SignalImpl;
}
