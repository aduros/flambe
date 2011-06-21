//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.server;

class Node
{
    public static var stringify :Dynamic -> String = untyped JSON.stringify;
    public static var parse :String -> Dynamic = untyped JSON.parse;
    public static var require :String -> Dynamic = untyped __js__("require");

    public static function puts (msg :String)
    {
        _sys.puts(msg);
    }

    private static var _sys = require("sys");
}
