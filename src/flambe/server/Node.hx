//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

// TODO(bruno): Use one of the nodejs externs on haxelib
class Node
{
    public static var require (_require, null) :String -> Dynamic;
    public static var console (_console, null) :Dynamic;
    public static var process (_process, null) :Dynamic;

    public static var stringify :Dynamic -> String = untyped JSON.stringify;
    public static var parse :String -> Dynamic = untyped JSON.parse;

    public static function log (message :String)
    {
        console.log(message);
    }

    inline public static function newBuffer (?data :String, ?encoding :String) :Dynamic
    {
        return untyped __js__("new Buffer")(data, encoding);
    }

    /** 'Error' isn't available in haXe, but it's the only way to get a stack trace. */
    inline public static function throwError (message :String)
    {
        throw untyped __js__("new Error")(message);
    }

    inline private static function _require () return untyped __js__("require")
    inline private static function _console () return untyped __js__("console")
    inline private static function _process () return untyped __js__("process")
}
