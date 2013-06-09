//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.subsystem.StorageSystem;

class DummyStorage
    implements StorageSystem
{
    public var supported (get, null) :Bool;

    public function new ()
    {
        clear();
    }

    public function get_supported () :Bool
    {
        return false;
    }

    public function set (key :String, value :Dynamic) :Bool
    {
        _hash.set(key, value);
        return true;
    }

    public function get<A> (key :String, defaultValue :A = null) :A
    {
        return _hash.exists(key) ? _hash.get(key) : defaultValue;
    }

    public function remove (key :String)
    {
        _hash.remove(key);
    }

    public function clear ()
    {
        _hash = new Map<String,Dynamic>();
    }

    private var _hash :Map<String,Dynamic>;
}
