package flambe.util;

typedef Listener0 = Void -> Void;

class Signal0
{
    public function new (?listener :Listener0)
    {
        _listeners = [];
        if (listener != null) {
            add(listener);
        }
    }

    public function add (listener :Listener0)
    {
        _listeners.push(listener);
    }

    public function remove (listener :Listener0)
    {
        _listeners.remove(listener);
    }

    public function emit ()
    {
        for (listener in _listeners) {
            listener();
        }
    }

    private var _listeners :Array<Listener0>;
}
