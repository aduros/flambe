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
    }

    public function log (level :LogLevel, message :String)
    {
        var levelPrefix = switch (level) {
            case Info: "INFO";
            case Warn: "WARN";
            case Error: "ERROR";
        }

        nativeTrace(levelPrefix + _tagPrefix + message);
    }

    private static var nativeTrace :String -> Void = untyped __global__["trace"];

    private var _tagPrefix :String;
}
