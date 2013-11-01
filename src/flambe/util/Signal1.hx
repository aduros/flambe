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
class Signal1<A> extends SignalBase
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener1<A>)
    {
        super(listener);
    }

    /**
     * Connects a listener to this signal.
     * @param prioritize True if this listener should fire before others.
     * @returns A SignalConnection, that can be disposed to remove the listener.
     */
    public function connect (listener :Listener1<A>, prioritize :Bool = false) :SignalConnection
    {
        return connectImpl(listener, prioritize);
    }

    /**
     * Emit the signal, notifying each connected listener.
     */
    public function emit (arg1 :A)
    {
        if (dispatching()) {
            defer(function () {
                emitImpl(arg1);
            });
        } else {
            emitImpl(arg1);
        }
    }

    private function emitImpl (arg1 :A)
    {
        var head = willEmit();
        var p = head;
        while (p != null) {
            p._listener(arg1);
            if (!p.stayInList) {
                p.dispose();
            }
            p = p._next;
        }
        didEmit(head);
    }
}
