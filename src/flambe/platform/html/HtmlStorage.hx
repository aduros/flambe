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
            _storage.setItem(key, value);
        } catch (error :Dynamic) {
            // Browser may throw QUOTA_EXCEEDED_ERR
            return false;
        }
        return true;
    }

    public function get (key :String) :String
    {
        return _storage.getItem(key);
    }

    public function remove (key :String)
    {
        _storage.removeItem(key);
    }

    public function clear ()
    {
        _storage.clear();
    }

    private var _storage :Dynamic;
}
