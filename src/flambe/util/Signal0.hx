//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * An alias for Signal0 listeners.
 */
typedef Listener0 = Void -> Void;

/**
 * A zero-argument signal. See Signal1 and Signal2 for different arities.
 */
class Signal0
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener0)
    {
        if (listener != null) {
            connect(listener);
        }
    }

    /**
     * Connects a listener to this signal.
     * @param prioritize True if this listener should fire before others.
     * @returns A SignalConnection, that can be disposed to remove the listener.
     */
    public function connect (listener :Listener0, prioritize :Bool = false) :SignalConnection
    {
        if (_impl == null) {
            _impl = createImpl();
        }
        return _impl.connect(listener, prioritize);
    }

    /**
     * Emit the signal, notifying each connected listener.
     */
    public function emit ()
    {
        if (_impl != null) {
            _impl.emit([]);
        }
    }

    /**
     * @returns A shallow copy of this signal.
     */
    public function clone () :Signal0
    {
        var copy = new Signal0();
        if (_impl != null) {
            copy._impl = _impl.clone();
        }
        return copy;
    }

    /**
     * @returns True if this signal has at least one listener.
     */
    public function hasListeners () :Bool
    {
        return _impl != null && _impl.hasListeners();
    }

    private function createImpl () :SignalImpl
    {
        return new SignalImpl();
    }

    private var _impl :SignalImpl;
}
