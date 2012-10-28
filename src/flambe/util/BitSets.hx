//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Utility mixins for bit sets. Designed to be imported with 'using' to supplement regular Ints with
 * bitset functions.
 */
class BitSets
{
    /**
     * Adds all the bits included in the mask, and returns the new bitset.
     */
    inline public static function add (bits :Int, mask :Int) :Int
    {
        return bits | mask;
    }

    /**
     * Removes all the bits included in the mask, and returns the new bitset.
     */
    inline public static function remove (bits :Int, mask :Int) :Int
    {
        return bits & ~mask;
    }

    /**
     * Toggles all the bits included in the mask, and returns the new bitset.
     */
    inline public static function toggle (bits :Int, mask :Int) :Int
    {
        return bits ^ mask;
    }

    /**
     * Returns true if the bitset contains ANY of the bits in the given mask.
     */
    inline public static function contains (bits :Int, mask :Int) :Bool
    {
        return bits & mask != 0;
    }

    /**
     * Returns true if the bitset contains ALL of the bits in the given mask.
     */
    inline public static function containsAll (bits :Int, mask :Int) :Bool
    {
        return bits & mask == mask;
    }

    /**
     * Either adds or removes all the bits included in the mask, and returns the new bitset.
     */
    public static function set (bits :Int, mask :Int, enabled :Bool) :Int
    {
        return enabled ? add(bits, mask) : remove(bits, mask);
    }
}
