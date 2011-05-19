package flambe.util;

typedef Listener2<A,B> = A -> B -> Void;

class Signal2<A,B>
{
    public function new (?listener :Listener2<A,B>)
    {
        if (listener != null) {
            connect(listener);
        }
    }

    public function connect (listener :Listener2<A,B>, prioritize :Bool = false) :SignalConnection
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

    public function emit (arg1 :A, arg2 :B)
    {
        if (_impl != null) {
            _impl.emit([ arg1, arg2 ]);
        }
    }

    private function createImpl () :SignalImpl
    {
        return new SignalImpl();
    }

    private var _impl :SignalImpl;
}
