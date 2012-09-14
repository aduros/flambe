//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

using StringTools;

/**
 * Utility mixins for Strings. Designed to be imported with 'using'.
 */
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
                code = Std.int(31*code + str.fastCodeAt(ii));
            }
        }
        return code;
    }

    /**
     * Substitute all "{n}" tokens with the corresponding values.
     * Example: <pre>substitute("{1} sat on a {0}", ["wall", "Humpty Dumpty"])</pre> returns
     * <pre>"Humpty Dumpty sat on a wall"</pre>.
     */
    public static function substitute (str :String, values :Array<Dynamic>) :String
    {
        // FIXME(bruno): If your {0} replacement has a {1} in it, then that'll get replaced next
        // iteration
        for (ii in 0...values.length) {
            str = str.replace("{" + ii + "}", values[ii]);
        }
        return str;
    }

    /**
     * Format a message with named parameters into a standard format for logging and errors.
     * Example: <pre>withFields("Wobbles were frobulated", ["count", 5, "silly", true])</pre> returns
     * <pre>"Wobbles were frobulated [count=5, silly=true]"</pre>.
     * @param fields The field names and values to be formatted. Must have an even length.
     */
    public static function withFields (message :String, fields :Array<Dynamic>) :String
    {
        var ll = fields.length;
        if (ll > 0) {
            message += (message.length > 0) ? " [" : "[";
            var ii = 0;
            while (ii < ll) {
                if (ii > 0) {
                    message += ", ";
                }
                var name = fields[ii];
                var value :Dynamic = fields[ii + 1];

                // Replace throwables with their stack trace
#if flash
                if (Std.is(value, flash.errors.Error)) {
                    var stack :String = cast(value, flash.errors.Error).getStackTrace();
                    if (stack != null) {
                        value = stack;
                    }
                }
#elseif js
                if (Std.is(value, untyped __js__("Error"))) {
                    var stack :String = value.stack;
                    if (stack != null) {
                        value = stack;
                    }
                }
#end
                message += name + "=" + value;
                ii += 2;
            }
            message += "]";
        }

        return message;
    }
}
