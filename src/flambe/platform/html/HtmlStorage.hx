//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.platform.Storage;

class HtmlStorage
    implements Storage
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public function new (storage :Dynamic)
    {
        _storage = storage;
    }

    public function set (key :String, value :String) :Bool
    {
        try {
            _storage.setItem(PREFIX + key, value);
        } catch (error :Dynamic) {
            // setItem may throw a QuotaExceededError:
            // http://dev.w3.org/html5/webstorage/#dom-localstorage
            log.warn("localStorage.setItem failed", ["message", error.message]);
            return false;
        }
        return true;
    }

    public function get (key :String) :String
    {
        try {
            return _storage.getItem(PREFIX + key);
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            log.warn("localStorage.getItem failed", ["message", error.message]);
        }
        return null;
    }

    public function remove (key :String)
    {
        try {
            _storage.removeItem(PREFIX + key);
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            log.warn("localStorage.removeItem failed", ["message", error.message]);
        }
    }

    public function clear ()
    {
        try {
            _storage.clear();
        } catch (error :Dynamic) {
            // This should never happen, but it sometimes does in Firefox and IE
            log.warn("localStorage.clear failed", ["message", error.message]);
        }
    }

    // Prefix localStorage keys to prevent collisions with other JS on the page
    private static inline var PREFIX = "flambe:";

    private var _storage :Dynamic;
}
