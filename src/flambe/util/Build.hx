//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
 * Useful build-time macros.
 */
class Build
{
    /**
     * Expands to the date at compile time, formatted as a string.
     */
    macro public static function date () :Expr
    {
        return Context.makeExpr(Date.now().toString(), Context.currentPos());
    }
}
