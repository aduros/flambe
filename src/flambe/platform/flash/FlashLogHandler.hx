//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flambe.util.Logger;

class FlashLogHandler
    implements LogHandler
{
    public function new (tag :String)
    {
        _tagPrefix = " " + tag + ": ";
        _trace = untyped __global__["trace"];
    }

    public function log (level :LogLevel, message :String)
    {
        var levelPrefix = switch (level) {
            case Info: "INFO";
            case Warn: "WARN";
            case Error: "ERROR";
        }

        _trace(levelPrefix + _tagPrefix + message);
    }

    private var _tagPrefix :String;
    private var _trace :String -> Void;
}
