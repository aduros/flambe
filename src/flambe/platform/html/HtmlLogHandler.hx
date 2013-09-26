//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.util.Logger;

class HtmlLogHandler
    implements LogHandler
{
    public static function isSupported () :Bool
    {
        return untyped __js__("typeof console") == "object" && __js__("console").info != null;
    }

    public function new (tag :String)
    {
        _tagPrefix = tag + ": ";
    }

    public function log (level :LogLevel, message :String)
    {
        message = _tagPrefix + message;

        switch (level) {
        case Info:
            (untyped __js__("console")).info(message);
        case Warn:
            (untyped __js__("console")).warn(message);
        case Error:
            (untyped __js__("console")).error(message);
        }
    }

    private var _tagPrefix :String;
}
