//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.net.SharedObject;

import haxe.Serializer;
import haxe.Unserializer;

import flambe.storage.Storage;

class NMEStorage
    implements Storage
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public var supported (isSupported, null) :Bool;

    public function new (so :SharedObject)
    {
        _so = so;
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function set (key :String, value :Dynamic) :Bool
    {
        var encoded :String;
        try {
            var serializer = new Serializer();
            serializer.useCache = true; // Allow circular references
            serializer.useEnumIndex = false; // Ensure persistence-friendly enums
            serializer.serialize(value);
            encoded = serializer.toString();
        } catch (error :Dynamic) {
            log.warn("Storage serialization failed", ["message", error]);
            return false;
        }

        _so.data[untyped key] = encoded;
        return true;
    }

    public function get (key :String) :Dynamic
    {
        var encoded :String = _so.data[untyped key];
        if (encoded != null) {
            try {
                return Unserializer.run(encoded);
            } catch (error :Dynamic) {
                log.warn("Storage unserialization failed", ["message", error]);
            }
        }
        return null;
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
