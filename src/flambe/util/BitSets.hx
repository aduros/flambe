//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;
import haxe.macro.Expr.ExprOf;

/**
 * Utility mixins for bit sets. Designed to be imported with 'using' to supplement regular Ints with
 * bitset functions.
 */
class BitSets
{
    /**
     * Adds all the bits included in the mask, and returns the new bitset.
     */
    macro public static function add (bits :ExprOf<Int>, mask :ExprOf<Int>) :ExprOf<Int>
    {
        return macro ($bits | $mask);
    }

    /**
     * Removes all the bits included in the mask, and returns the new bitset.
     */
    macro public static function remove (bits :ExprOf<Int>, mask :ExprOf<Int>) :ExprOf<Int>
    {
        return macro ($bits & ~$mask);
    }

    /**
     * Toggles all the bits included in the mask, and returns the new bitset.
     */
    macro public static function toggle (bits :ExprOf<Int>, mask :ExprOf<Int>) :ExprOf<Int>
    {
        return macro $bits ^ $mask;
    }

    /**
     * Returns true if the bitset contains ANY of the bits in the given mask.
     */
    macro public static function contains (bits :ExprOf<Int>, mask :ExprOf<Int>) :ExprOf<Bool>
    {
        return macro (($bits & $mask) != 0);
    }

    /**
     * Returns true if the bitset contains ALL of the bits in the given mask.
     */
    macro public static function containsAll (bits :ExprOf<Int>, mask :ExprOf<Int>) :ExprOf<Bool>
    {
        return macro (($bits & $mask) == $mask);
    }

    /**
     * Either adds or removes all the bits included in the mask, and returns the new bitset.
     */
    macro public static function set (bits :ExprOf<Int>, mask :ExprOf<Int>, enabled :ExprOf<Bool>) :ExprOf<Int>
    {
       return macro ($enabled ? ($bits | $mask) : ($bits & ~$mask));
    }
}
