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
class Signal2<A,B> extends SignalBase
{
    /**
     * @param listener An optional listener to immediately connect to the signal.
     */
    public function new (?listener :Listener2<A,B>)
    {
        super(listener);
    }

    /**
     * Connects a listener to this signal.
     * @param prioritize True if this listener should fire before others.
     * @returns A SignalConnection, that can be disposed to remove the listener.
     */
    public function connect (listener :Listener2<A,B>, prioritize :Bool = false) :SignalConnection
    {
        return connectImpl(listener, prioritize);
    }

    /**
     * Emit the signal, notifying each connected listener.
     */
    public function emit (arg1 :A, arg2 :B)
    {
        if (dispatching()) {
            defer(function () {
                emitImpl(arg1, arg2);
            });
        } else {
            emitImpl(arg1, arg2);
        }
    }

    private function emitImpl (arg1 :A, arg2 :B)
    {
        var head = willEmit();
        var p = head;
        while (p != null) {
            p._listener(arg1, arg2);
            if (!p.stayInList) {
                p.dispose();
            }
            p = p._next;
        }
        didEmit(head);
    }
}
