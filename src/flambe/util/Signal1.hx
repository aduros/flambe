//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

typedef Listener1<A> = A -> Void;

class Signal1<A>
{
    public function new (?listener :Listener1<A>)
    {
        if (listener != null) {
            connect(listener);
        }
    }

    public function connect (listener :Listener1<A>, prioritize :Bool = false) :SignalConnection
    {
        if (_impl == null) {
            _impl = createImpl();
        }
        return _impl.connect(listener, prioritize);
    }

    public function disconnectAll ()
    {
        if (_impl != null) {
            _impl.disconnectAll();
        }
    }

    public function emit (arg1 :A)
    {
        if (_impl != null) {
            _impl.emit([ arg1 ]);
        }
    }

    public function clone () :Signal1<A>
    {
        var copy = new Signal1<A>();
        if (_impl != null) {
            copy._impl = _impl.clone();
        }
        return copy;
    }

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
