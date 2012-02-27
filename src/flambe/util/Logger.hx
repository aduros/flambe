//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

enum LogLevel {
    /** General helpful information. */
    Info;

    /** An unexpected, but recoverable problem. */
    Warn;

    /** A fatal, unrecoverable problem. */
    Error;
}

interface LogHandler
{
    public function log (level :LogLevel, message :String) :Void;
}

class Logger
{
    public function new (handler :LogHandler)
    {
        _handler = handler;
    }

#if flambe_disable_logging
    // In release builds, logging calls are completely stripped out
    inline public function info (?text :String, ?args :Array<Dynamic>) { }
    inline public function warn (?text :String, ?args :Array<Dynamic>) { }
    inline public function error (?text :String, ?args :Array<Dynamic>) { }
    inline public function log (level :LogLevel, ?text :String, ?args :Array<Dynamic>) { }

#else
    public function info (?text :String, ?args :Array<Dynamic>)
    {
        log(Info, text, args);
    }

    public function warn (?text :String, ?args :Array<Dynamic>)
    {
        log(Warn, text, args);
    }

    public function error (?text :String, ?args :Array<Dynamic>)
    {
        log(Error, text, args);
    }

    public function log (level :LogLevel, ?text :String, ?args :Array<Dynamic>)
    {
        if (_handler == null) {
            return; // No handler, carry on quietly
        }

        if (text == null) {
            text = "";
        }

        if (args != null) {
            var ll = args.length;
            if (ll > 0) {
                text += (text.length > 0) ? " [" : "[";
                var ii = 0;
                while (ii < ll) {
                    if (ii > 0) {
                        text += ", ";
                    }
                    text += args[ii] + "=" + args[ii+1];
                    ii += 2;
                }
                text += "]";
            }
        }

        _handler.log(level, text);
    }
#end

    private var _handler :LogHandler;
}
