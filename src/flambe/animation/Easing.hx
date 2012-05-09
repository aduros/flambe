//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

/** Receives and returns a number between [0,1]. */
typedef EasingFunction = Float -> Float;

class Easing
{
    public static function linear (r :Float) :Float
    {
        return r;
    }

    public static function quadIn (r :Float) :Float
    {
        return r*r;
    }

    public static function quadOut (r :Float) :Float
    {
        return r*(2-r);
    }

    public static function quadInOut (r :Float) :Float
    {
        return (r < 0.5) ? 2*r*r : -2*r*(r-2)-1;
    }

    public static function bounceIn (r :Float) :Float
    {
        return bounceOut(1 - r);
    }

    public static function bounceOut (r :Float) :Float
    {
        if (r < (1/2.75)) {
            return 7.5625*r*r;
        } else if (r < (2/2.75)) {
            return 7.5625*(r-=(1.5/2.75))*r + 0.75;
        } else if (r < (2.5/2.75)) {
            return 7.5625*(r-=(2.25/2.75))*r + 0.9375;
        } else {
            return 7.5625*(r-=(2.625/2.75))*r + 0.984375;
        }
    }

    public static function backIn (r :Float) :Float
    {
        var s = 1.70158;
        return r*r*((s+1)*r - s);
    }

    public static function backOut (r :Float) :Float
    {
        var s = 1.70158;
        --r;
        return r*r*((s+1)*r + s) + 1;
    }
}
