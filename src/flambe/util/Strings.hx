//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

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
                code = 31*code + str.fastCodeAt(ii);
            }
        }
        return code;
    }
}
