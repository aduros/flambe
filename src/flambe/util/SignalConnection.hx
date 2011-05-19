package flambe.util;

class SignalConnection
    implements Disposable
{
    public var stayInList (default, null) :Bool;

    public function new (signal :SignalImpl, listener :Dynamic)
    {
        _internal_signal = signal;
        _internal_listener = listener;
        stayInList = true;
    }

    public function once ()
    {
        stayInList = false;
        return this;
    }

    public function dispose ()
    {
        if (_internal_signal != null) {
            _internal_signal.disconnect(this);
        }
    }

    public var _internal_listener :Dynamic;
    public var _internal_signal :SignalImpl;
}
