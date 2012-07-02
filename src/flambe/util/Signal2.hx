//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * An alias for Signal2 listeners.
 */
typedef Listener2<A,B> = A -> B -> Void;

/**
 * A two-argument signal. See Signal0 and Signal1 for different arities.
 */
class Signal2<A,B>
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener2<A,B>)
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
    public function connect (listener :Listener2<A,B>, prioritize :Bool = false) :SignalConnection
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
    public function emit (arg1 :A, arg2 :B)
    {
        if (_impl != null) {
            _impl.emit([ arg1, arg2 ]);
        }
    }

    /**
     * @returns A shallow copy of this signal.
     */
    public function clone () :Signal2<A,B>
    {
        var copy = new Signal2<A,B>();
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
