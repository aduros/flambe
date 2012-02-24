//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import haxe.xml.Fast;

class Xmls
{
    public static function getStringAttr (reader :Fast, attr :String, def :String = null)
    {
        if (reader.has.resolve(attr)) {
            return reader.att.resolve(attr);
        }
        return def;
    }

    public static function getFloatAttr (reader :Fast, attr :String, def :Float = 0)
    {
        if (reader.has.resolve(attr)) {
            return Std.parseFloat(reader.att.resolve(attr));
        }
        return def;
    }

    public static function getIntAttr (reader :Fast, attr :String, def :Int = 0)
    {
        if (reader.has.resolve(attr)) {
            return Std.parseInt(reader.att.resolve(attr));
        }
        return def;
    }
}
