//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

class DummyStorage
    implements Storage
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public var supported (isSupported, null) :Bool;

    public function new ()
    {
        clear();
    }

    public function isSupported () :Bool
    {
        return false;
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
