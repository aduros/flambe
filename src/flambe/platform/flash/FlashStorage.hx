//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.net.SharedObject;

import flambe.platform.Storage;

class FlashStorage
    implements Storage
{
    public var supported (isSupported, null) :Bool;

    public function new (so :SharedObject)
    {
        _so = so;
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function set (key :String, value :String) :Bool
    {
        _so.data[untyped key] = value;
        return true;
    }

    public function get (key :String) :String
    {
        return _so.data[untyped key];
    }

    public function remove (key :String)
    {
        untyped __delete__(_so.data, key);
    }

    public function clear ()
    {
        _so.clear();
    }

    private var _so :SharedObject;
}
