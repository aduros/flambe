//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Utility mixins for Maps. Designed to be imported with 'using'.
 */
class Maps
{
    /**
     * Fetch a string from a hash, converting it from another type if necessary.
     * @param defaultValue The value to return if the key was not found.
     */
    public static function getString (
        hash :Map<String,Dynamic>, key :String, defaultValue :String = null) :String
    {
        var value = hash.get(key);
        return (value != null) ? ""+value : defaultValue;
    }

    /**
     * Fetch a float from a hash, converting it from another type if necessary.
     * @param defaultValue The value to return if the key was not found.
     */
    public static function getFloat (
        hash :Map<String,Dynamic>, key :String, defaultValue :Float = 0) :Float
    {
        var value = hash.get(key);
        return (value != null) ? Std.parseFloat(""+value) : defaultValue;
    }

    /**
     * Fetch a integer from a hash, converting it from another type if necessary.
     * @param defaultValue The value to return if the key was not found.
     */
    public static function getInt (
        hash :Map<String,Dynamic>, key :String, defaultValue :Int = 0) :Int
    {
        var value = hash.get(key);
        return (value != null) ? Std.parseInt(""+value) : defaultValue;
    }

    /**
     * Fetch a boolean from a hash, converting it from another type if necessary.
     * @param defaultValue The value to return if the key was not found.
     */
    public static function getBool (
        hash :Map<String,Dynamic>, key :String, defaultValue :Bool = false) :Bool
    {
        var value = hash.get(key);
        return (value != null) ? value != 0 && value != false && value != "false" : defaultValue;
    }
}
