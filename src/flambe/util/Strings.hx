//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

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
}
