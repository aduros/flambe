//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

using flambe.util.Strings;

/**
 * Represents the severity of a log message.
 */
enum LogLevel {
    /** General helpful information. */
    Info;

    /** An unexpected but recoverable problem. */
    Warn;

    /** A fatal, unrecoverable problem. */
    Error;
}

interface LogHandler
{
    function log (level :LogLevel, message :String) :Void;
}

/**
 * A logging system, for printing formatted debug messages. Logging is stripped from release builds,
 * unless the `-D flambe_keep_logs` compiler flag is used.
 *
 * ```haxe
 * var log = System.createLogger("mygame");
 * log.info("Player logged in", ["name", "Joe", "level", 24]);
 * // Logs "INFO mygame: Player logged in [name=Joe, level=24]"
 * ```
 *
 * See `PackageLog` for a handy way to setup logging across a whole project.
 */
class Logger
{
    /**
     * @param handler The handler that logs will be sent to for printing.
     */
    public function new (handler :LogHandler)
    {
        _handler = handler;
    }

#if (debug || flambe_keep_logs)
    /**
     * Logs a message at the `Info` severity level.
     *
     * @param text The message to log.
     * @param fields Extra information to be formatted with `Strings.withFields`.
     */
    public function info (?text :String, ?fields :Array<Dynamic>)
    {
        log(Info, text, fields);
    }

    /**
     * Logs a message at the `Warn` severity level.
     *
     * @param text The message to log.
     * @param fields Extra information to be formatted with `Strings.withFields`.
     */
    public function warn (?text :String, ?fields :Array<Dynamic>)
    {
        log(Warn, text, fields);
    }

    /**
     * Logs a message at the `Error` severity level.
     *
     * @param text The message to log.
     * @param fields Extra information to be formatted with `Strings.withFields`.
     */
    public function error (?text :String, ?fields :Array<Dynamic>)
    {
        log(Error, text, fields);
    }

    /**
     * Logs a message at the given severity level.
     *
     * @param level The severity of the log message.
     * @param text The message to log.
     * @param fields Extra information to be formatted with `Strings.withFields`.
     */
    public function log (level :LogLevel, ?text :String, ?fields :Array<Dynamic>)
    {
        if (_handler == null) {
            return; // No handler, carry on quietly
        }
        if (text == null) {
            text = "";
        }
        if (fields != null) {
            text = text.withFields(fields);
        }
        _handler.log(level, text);
    }

#else
    // In release builds, logging calls are stripped out
    inline public function info (?text :String, ?fields :Array<Dynamic>) {}
    inline public function warn (?text :String, ?fields :Array<Dynamic>) {}
    inline public function error (?text :String, ?fields :Array<Dynamic>) {}
    inline public function log (level :LogLevel, ?text :String, ?fields :Array<Dynamic>) {}
#end

    private var _handler :LogHandler;
}
