//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.util.Signal1;
import flambe.util.SignalConnection;
import flambe.util.Value;

/** An internal Signal1 with extra frills. */
class HeavySignal1<A> extends Signal1<A>
{
    /**
     * A watchable value, for detecting when the first listener was connected, or the last
     * connection was disposed.
     */
    public var hasListenersValue (default, null) :Value<Bool>;

    public function new (?listener :Listener1<A>)
    {
        super(listener);
        hasListenersValue = new Value<Bool>(hasListeners());
    }

    override public function connect (listener :Listener1<A>, prioritize :Bool = false) :SignalConnection
    {
        var connection = super.connect(listener, prioritize);
        hasListenersValue._ = hasListeners();
        return connection;
    }

    override private function disconnect (conn :SignalConnection)
    {
        super.disconnect(conn);
        hasListenersValue._ = hasListeners();
    }

    override private function didEmit (head :SignalConnection)
    {
        super.didEmit(head);
        hasListenersValue._ = hasListeners();
    }
}
