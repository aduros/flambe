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
class Signal0 extends SignalBase
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener0)
    {
        super(listener);
    }

    /**
     * Connects a listener to this signal.
     * @param prioritize True if this listener should fire before others.
     * @returns A SignalConnection, that can be disposed to remove the listener.
     */
    public function connect (listener :Listener0, prioritize :Bool = false) :SignalConnection
    {
        return connectImpl(listener, prioritize);
    }

    /**
     * Emit the signal, notifying each connected listener.
     */
    public function emit ()
    {
        if (dispatching()) {
            defer(function () {
                emitImpl();
            });
        } else {
            emitImpl();
        }
    }

    private function emitImpl ()
    {
        var head = willEmit();
        var p = head;
        while (p != null) {
            p._listener();
            if (!p.stayInList) {
                p.dispose();
            }
            p = p._next;
        }
        didEmit(head);
    }
}
