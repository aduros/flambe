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
        return untyped __js__("typeof console") == "object" && console.info != null;
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
            (untyped console).info(message);
        case Warn:
            (untyped console).warn(message);
        case Error:
            (untyped console).error(message);
        }
    }

    private var _tagPrefix :String;
}
