//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

typedef Listener0 = Void -> Void;

class Signal0
{
    public function new (?listener :Listener0)
    {
        if (listener != null) {
            connect(listener);
        }
    }

    public function connect (listener :Listener0, prioritize :Bool = false) :SignalConnection
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

    public function emit ()
    {
        if (_impl != null) {
            _impl.emit([]);
        }
    }

    public function clone () :Signal0
    {
        var copy = new Signal0();
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
