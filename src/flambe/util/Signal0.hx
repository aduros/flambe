package flambe.util;

typedef Listener0 = Void -> Void;

class Signal0
{
    public function new ()
    {
        _slots = [];
    }

    public function add (slot :Listener0)
    {
        _slots.push(slot);
    }

    public function remove (slot :Listener0)
    {
        _slots.remove(slot);
    }

    public function emit ()
    {
        for (slot in _slots) {
            slot();
        }
    }

    private var _slots :Array<Listener0>;
}
