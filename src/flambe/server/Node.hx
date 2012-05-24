//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

import flambe.util.Logger;

// TODO(bruno): Use one of the nodejs externs on haxelib
class Node
{
    public static var require (_require, null) :String -> Dynamic;
    public static var console (_console, null) :Dynamic;
    public static var process (_process, null) :Dynamic;

    // TODO(bruno): Use haxe's JSON API
    public static var stringify :Dynamic -> String = untyped JSON.stringify;
    public static var parse :String -> Dynamic = untyped JSON.parse;

    // FIXME(bruno): Multiple loggers with different tags is not supported
    public static function logger (tag :String) :Logger
    {
        var handler :LogHandler = new flambe.platform.html.HtmlLogHandler(tag);
#if !debug
        // Try to log to the syslog in production builds
        try {
            var syslog = require("node-syslog");
            handler = new SystemLogHander(syslog, tag);
        } catch (error :Dynamic) {
            // node-syslog probably not installed, include it in your npmLibs
        }
#end
        return new Logger(handler);
    }

    inline public static function newBuffer (?data :String, ?encoding :String) :Dynamic
    {
        return untyped __js__("new Buffer")(data, encoding);
    }

    /** 'Error' isn't available in Haxe, but it's the only way to get a stack trace. */
    inline public static function throwError (message :String)
    {
        throw untyped __js__("new Error")(message);
    }

    inline private static function _require () return untyped __js__("require")
    inline private static function _console () return untyped __js__("console")
    inline private static function _process () return untyped __js__("process")
}
