//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.animation;

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
}
