//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import flambe.util.Logger;

#else

/**
 * Classes that extend PackageLog will have static logging methods generated for them. The methods
 * correspond to the methods in `Logger`.
 *
 * Creating a class that extends PackageLog at the base of your project is a convenient way to
 * include logging across a whole codebase. The package name is used as the log tag.
 *
 * ```haxe
 * // In src/foobar/Log.hx
 * class Log extends PackageLog {}
 *
 * // In src/foobar/something/deeper/Widget.hx
 * // (Importing foobar.Log is not needed, as Haxe automatically imports classes in parent directories)
 * Log.info("Hello world"); // Logs "foobar: Hello world"
 * ```
 */
@:autoBuild(flambe.util.PackageLog.build())
#end
class PackageLog
{
#if macro
    public static function build () :Array<Field>
    {
        var pos = Context.currentPos();
        var cl = Context.getLocalClass().get();

        var tag = Context.makeExpr(cl.pack.join("."), pos);
        var logger = Context.defined("flambe-server")
            ? macro flambe.server.Node.createLogger($tag)
            : macro flambe.System.createLogger($tag);

        return Macros.buildFields(macro {
            var public__static__logger :flambe.util.Logger = $logger;

            function inline__public__static__info (?text :String, ?args :Array<Dynamic>) {
                logger.info(text, args);
            }

            function inline__public__static__warn (?text :String, ?args :Array<Dynamic>) {
                logger.warn(text, args);
            }

            function inline__public__static__error (?text :String, ?args :Array<Dynamic>) {
                logger.error(text, args);
            }

            function inline__public__static__log (level :flambe.util.Logger.LogLevel,
                    ?text :String, ?args :Array<Dynamic>) {
                logger.log(level, text, args);
            }
        }).concat(Context.getBuildFields());
    }
#end
}
