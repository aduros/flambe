//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.storage.Storage;

class DummyStorage
    implements Storage
{
    public var supported (isSupported, null) :Bool;

    public function new ()
    {
        clear();
    }

    public function isSupported () :Bool
    {
        return false;
    }

    public function set (key :String, value :Dynamic) :Bool
    {
        _hash.set(key, value);
        return true;
    }

    public function get (key :String) :Dynamic
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

    private var _hash :Hash<Dynamic>;
}
