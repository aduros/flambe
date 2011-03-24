package flambe.util;

typedef Slot2<A,B> = A -> B -> Void;

class Signal2<A,B>
{
    public function new ()
    {
        _slots = [];
    }

    public function add (slot :Slot2<A,B>)
    {
        _slots.push(slot);
    }

    public function remove (slot :Slot2<A,B>)
    {
        _slots.remove(slot);
    }

    public function emit (a :A, b :B)
    {
        for (slot in _slots) {
            slot(a, b);
        }
    }

    private var _slots :Array<Slot2<A,B>>;
}
