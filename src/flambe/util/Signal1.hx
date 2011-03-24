package flambe.util;

typedef Listener1<A> = A -> Void;

class Signal1<A>
{
    public function new (?listener :Listener1<A>)
    {
        _listeners = [];
        if (listener != null) {
            add(listener);
        }
    }

    public function add (listener :Listener1<A>)
    {
        _listeners.push(listener);
    }

    public function remove (listener :Listener1<A>)
    {
        _listeners.remove(listener);
    }

    public function emit (signal :A)
    {
        for (listener in _listeners) {
            listener(signal);
        }
    }

    private var _listeners :Array<Listener1<A>>;
}
