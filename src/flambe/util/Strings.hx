//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.math.FMath;

using StringTools;

class Strings
{
    /**
     * Gets the extension of a file name or URL, or null if there is no extension.
     */
    public static function getFileExtension (fileName :String) :String
    {
        var start = fileName.lastIndexOf(".") + 1;
        return (start > 1 && start < fileName.length) ? fileName.substr(start) : null;
    }

    public static function hashCode (str :String) :Int
    {
        var code = 0;
        if (str != null) {
            for (ii in 0...str.length) {
                code = FMath.toInt(31*code + str.fastCodeAt(ii));
            }
        }
        return code;
    }

    public static function substitute (str :String, values :Array<Dynamic>)
    {
        // FIXME(bruno): If your {0} replacement has a {1} in it, then that'll get replaced next
        // iteration
        for (ii in 0...values.length) {
            str = str.replace("{" + ii + "}", values[ii]);
        }
        return str;
    }
}
