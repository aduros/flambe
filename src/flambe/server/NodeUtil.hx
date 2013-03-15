//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

import flambe.util.Logger;

// TODO(bruno): Use one of the nodejs externs on haxelib
class NodeUtil
{
    // public static var require (get, null) :String -> Dynamic;
    // public static var console (get, null) :Dynamic;
    // public static var process (get, null) :Dynamic;

    // FIXME(bruno): Creating multiple loggers with different tags are not supported
    public static function createLogger (tag :String) :Logger
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

    // inline private static function get_require () return untyped __js__("require");
    // inline private static function get_console () return untyped __js__("console");
    // inline private static function get_process () return untyped __js__("process");
}
