//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import flambe.util.Logger;

class NMELogHandler
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

        trace(levelPrefix + _tagPrefix + message);
    }

    private var _tagPrefix :String;
}
