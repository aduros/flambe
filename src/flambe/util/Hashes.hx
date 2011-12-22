//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

class Hashes
{
    /**
     * Fetch a string from a dynamic Hash, or a default value if one doesn't exist.
     */
    public static function getString (
        hash :Hash<Dynamic>, key :String, defaultValue :String = null) :String
    {
        var value = hash.get(key);
        return (value != null) ? ""+value : defaultValue;
    }

    public static function getFloat (
        hash :Hash<Dynamic>, key :String, defaultValue :Float = 0) :Float
    {
        var value = hash.get(key);
        return (value != null) ? Std.parseFloat(""+value) : defaultValue;
    }

    public static function getInt (
        hash :Hash<Dynamic>, key :String, defaultValue :Int = 0) :Float
    {
        var value = hash.get(key);
        return (value != null) ? Std.parseInt(""+value) : defaultValue;
    }
}
