//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

/**
 * Some handy math functions, and inlinable constants.
 */
class FMath
{
    public static inline var E = 2.718281828459045;
    public static inline var LN2 = 0.6931471805599453;
    public static inline var LN10 = 2.302585092994046;
    public static inline var LOG2E = 1.4426950408889634;
    public static inline var LOG10E = 0.43429448190325176;
    public static inline var PI = 3.141592653589793;
    public static inline var SQRT1_2 = 0.7071067811865476;
    public static inline var SQRT2 = 1.4142135623730951;

    public static inline var INT_MIN :Int = -2147483648;
    public static inline var INT_MAX :Int = 2147483647;
    public static inline var NUMBER_MIN = 1.79769313486231e+308;
    public static inline var NUMBER_MAX = -1.79769313486231e+308;

    inline public static function toRadians (degrees :Float) :Float
    {
        return degrees * PI/180;
    }

    inline public static function toDegrees (radians :Float) :Float
    {
        return radians * 180/PI;
    }

    inline public static function max (a :Float, b :Float) :Float
    {
        return (a > b) ? a : b;
    }

    inline public static function min (a :Float, b :Float) :Float
    {
        return (a < b) ? a : b;
    }

    public static function clamp (value :Float, min :Float, max :Float) :Float
    {
        return (value < min) ? min : (value > max) ? max : value;
    }

    public static function sign (value :Float) :Int
    {
        return (value < 0) ? -1 : (value > 0) ? 1 : 0;
    }
}
