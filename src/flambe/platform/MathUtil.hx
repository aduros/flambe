//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

class MathUtil
{
    /**
     * Returns the smallest power of two >= n.
     */
    public static function nextPowerOfTwo (n :Int) :Int
    {
        var p = 1;
        while (p < n) {
            p <<= 1;
        }
        return p;
    }
}
