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

    /** An unexpected, but recoverable problem. */
    Warn;

    /** A fatal, unrecoverable problem. */
    Error;
}

interface LogHandler
{
    function log (level :LogLevel, message :String) :Void;
}

/**
 * A logging system, for printing formatted debug messages. Logging is stripped from release
 * builds, unless the -D flambe_keep_logs compiler flag is used.
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
     * @param args A list of pairs that are formatted into extra information. For example,
     *   `log.info("Player logged in", ["who", playerId, "level", 24])` will log something
     *   like: `INFO urgame: Player logged in [who=aduros, level=24]`
     */
    public function info (?text :String, ?args :Array<Dynamic>)
    {
        log(Info, text, args);
    }

    /**
     * Logs a message at the `Warn` severity level.
     *
     * @param text The message to log.
     * @param args A list of pairs that are formatted into extra information. For example,
     *   `log.warn("Player disconnected abruptly", ["who", playerId, "level", 24])` will log
     *   something like: `WARN urgame: Player disconnected abruptly [who=aduros, level=24]`
     */
    public function warn (?text :String, ?args :Array<Dynamic>)
    {
        log(Warn, text, args);
    }

    /**
     * Logs a message at the `Error` severity level.
     *
     * @param text The message to log.
     * @param args A list of pairs that are formatted into extra information. For example,
     *   `log.error("Couldn't connect to DB!", ["who", playerId, "level", 24])` will log something
     *   like: `ERROR urgame: Couldn't connect to DB! [who=aduros, level=24]`
     */
    public function error (?text :String, ?args :Array<Dynamic>)
    {
        log(Error, text, args);
    }

    /**
     * Logs a message.
     *
     * @param level The severity of the log message.
     * @param text The message to log.
     * @param args A list of pairs that are formatted into extra information. For example,
     *   `log.info("Player logged in", ["who", playerId, "level", 24])` will log something like:
     *   `INFO urgame: Player logged in [who=aduros, level=24]`
     */
    public function log (level :LogLevel, ?text :String, ?args :Array<Dynamic>)
    {
        if (_handler == null) {
            return; // No handler, carry on quietly
        }
        if (text == null) {
            text = "";
        }
        if (args != null) {
            text = text.withFields(args);
        }
        _handler.log(level, text);
    }

#else
    // In release builds, logging calls are stripped out
    inline public function info (?text :String, ?args :Array<Dynamic>) {}
    inline public function warn (?text :String, ?args :Array<Dynamic>) {}
    inline public function error (?text :String, ?args :Array<Dynamic>) {}
    inline public function log (level :LogLevel, ?text :String, ?args :Array<Dynamic>) {}
#end

    private var _handler :LogHandler;
}
