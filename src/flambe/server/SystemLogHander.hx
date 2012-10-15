//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

import flambe.util.Logger;

class SystemLogHander
    implements LogHandler
{
    public function new (syslog :Dynamic, tag :String)
    {
        _syslog = syslog;
        _syslog.init(tag, syslog.LOG_PID, syslog.LOG_LOCAL0);
    }

    public function log (level :LogLevel, message :String)
    {
        var sysLevel = switch (level) {
            case Info: _syslog.LOG_INFO;
            case Warn: _syslog.LOG_WARNING;
            case Error: _syslog.LOG_ERR;
        };
        _syslog.log(sysLevel, message);
    }

    private var _syslog :Dynamic;
}
