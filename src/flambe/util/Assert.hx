//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Simple runtime assertions. A failed assertion throws an error, which should NOT be caught and
 * handled. Assertions are stripped from release builds, unless the -D flambe_keep_asserts compiler
 * flag is used.
 */
class Assert
{
#if (debug || flambe_keep_asserts)
    /**
     * Asserts that a condition is true.
     * @param message If this assertion fails, the message to include in the thrown error.
     */
    public static function that (condition :Bool, ?message :String)
    {
        if (!condition) {
            fail(message);
        }
    }

    /**
     * Immediately fails an assertion. Same as Assert.that(false)
     * @param message The message to include in the thrown error.
     */
    public static function fail (?message :String)
    {
        throw "Assertion failed" + (message != null ? ": " + message : "");
    }

#else
    // In release builds, assertions are stripped out
    inline public static function that (condition :Bool, ?message :String) {}
    inline public static function fail (?message :String) {}
#end
}
