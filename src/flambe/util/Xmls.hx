//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import haxe.xml.Fast;

/**
 * Utility mixins for haxe.xml.Fast objects. Designed to be imported with 'using'.
 */
class Xmls
{
    public static function getStringAttr (reader :Fast, attr :String, def :String = null) :String
    {
        if (reader.has.resolve(attr)) {
            return reader.att.resolve(attr);
        }
        return def;
    }

    public static function getFloatAttr (reader :Fast, attr :String, def :Float = 0) :Float
    {
        if (reader.has.resolve(attr)) {
            var value = Std.parseFloat(reader.att.resolve(attr));
            if (!Math.isNaN(value)) {
                return value;
            }
        }
        return def;
    }

    public static function getIntAttr (reader :Fast, attr :String, def :Int = 0) :Int
    {
        if (reader.has.resolve(attr)) {
            var value = Std.parseInt(reader.att.resolve(attr));
            if (value != null) {
                return value;
            }
        }
        return def;
    }
}
