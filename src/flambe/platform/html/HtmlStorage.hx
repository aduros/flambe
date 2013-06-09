//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import haxe.Serializer;
import haxe.Unserializer;

import flambe.subsystem.StorageSystem;

class HtmlStorage
    implements StorageSystem
{
    public var supported (get, null) :Bool;

    public function new (storage :Dynamic)
    {
        _storage = storage;
    }

    public function get_supported () :Bool
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
            Log.warn("Storage serialization failed", ["message", error]);
            return false;
        }

        try {
            _storage.setItem(PREFIX + key, encoded);
        } catch (error :Dynamic) {
            // setItem may throw a QuotaExceededError:
            // http://dev.w3.org/html5/webstorage/#dom-localstorage
            Log.warn("localStorage.setItem failed", ["message", error.message]);
            return false;
        }
        return true;
    }

    public function get<A> (key :String, defaultValue :A = null) :A
    {
        var encoded :String = null;
        try {
            encoded = _storage.getItem(PREFIX + key);
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            Log.warn("localStorage.getItem failed", ["message", error.message]);
        }

        if (encoded != null) {
            try {
                return Unserializer.run(encoded);
            } catch (error :Dynamic) {
                Log.warn("Storage unserialization failed", ["message", error]);
            }
        }
        return defaultValue;
    }

    public function remove (key :String)
    {
        try {
            _storage.removeItem(PREFIX + key);
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            Log.warn("localStorage.removeItem failed", ["message", error.message]);
        }
    }

    public function clear ()
    {
        try {
            _storage.clear();
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            Log.warn("localStorage.clear failed", ["message", error.message]);
        }
    }

    // Prefix localStorage keys to prevent collisions with other JS on the page
    private static inline var PREFIX = "flambe:";

    private var _storage :Dynamic;
}
