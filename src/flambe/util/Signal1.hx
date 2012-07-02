//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * An alias for Signal1 listeners.
 */
typedef Listener1<A> = A -> Void;

/**
 * A one-argument signal. See Signal0 and Signal2 for different arities.
 */
class Signal1<A>
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener1<A>)
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
    public function connect (listener :Listener1<A>, prioritize :Bool = false) :SignalConnection
    {
        if (_impl == null) {
            _impl = createImpl();
        }
        return _impl.connect(listener, prioritize);
    }

    /**
     * Removes all listeners connected to this signal.
     */
    public function disconnectAll ()
    {
        if (_impl != null) {
            _impl.disconnectAll();
        }
    }

    /**
     * Emit the signal, notifying each connected listener.
     */
    public function emit (arg1 :A)
    {
        if (_impl != null) {
            _impl.emit([ arg1 ]);
        }
    }

    /**
     * @returns A shallow copy of this signal.
     */
    public function clone () :Signal1<A>
    {
        var copy = new Signal1<A>();
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
