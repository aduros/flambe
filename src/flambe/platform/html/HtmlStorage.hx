//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.platform.Storage;

class HtmlStorage
    implements Storage
{
    public function new (storage :Dynamic)
    {
        _storage = storage;
    }

    public function set (key :String, value :String) :Bool
    {
        try {
            _storage.setItem(PREFIX + key, value);
        } catch (error :Dynamic) {
            // Browser may throw QUOTA_EXCEEDED_ERR
            return false;
        }
        return true;
    }

    public function get (key :String) :String
    {
        return _storage.getItem(PREFIX + key);
    }

    public function remove (key :String)
    {
        _storage.removeItem(PREFIX + key);
    }

    public function clear ()
    {
        _storage.clear();
    }

    // Prefix localStorage keys to prevent collisions with other JS on the page
    private static inline var PREFIX = "flambe:";

    private var _storage :Dynamic;
}
