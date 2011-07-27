//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

class DummyStorage
    implements Storage
{
    public function new ()
    {
        clear();
    }

    public function set (key :String, value :String) :Bool
    {
        _hash.set(key, value);
        return true;
    }

    public function get (key :String) :String
    {
        return _hash.get(key);
    }

    public function remove (key :String)
    {
        _hash.remove(key);
    }

    public function clear ()
    {
        _hash = new Hash();
    }

    private var _hash :Hash<String>;
}
