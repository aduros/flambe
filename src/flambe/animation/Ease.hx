//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

import flambe.math.FMath;

/** Receives and returns a number between [0,1]. */
typedef EaseFunction = Float -> Float;

/**
 * Easing functions that can be used to animate values. For a cheat sheet, see <http://easings.net>.
 */
class Ease
{
    // Adapted from FlashPunk:
    // https://github.com/Draknek/FlashPunk/blob/master/net/flashpunk/utils/Ease.as
    //
    // Operation of in/out easers:
    //
    // in(t)
    //        return t;
    // out(t)
    //         return 1 - in(1 - t);
    // inOut(t)
    //         return (t <= .5) ? in(t * 2) / 2 : out(t * 2 - 1) / 2 + .5;

    /** Linear, no easing. */
    public static function linear (t :Float) :Float
    {
        return t;
    }

    /** Quadratic in. */
    public static function quadIn (t :Float) :Float
    {
        return t * t;
    }

    /** Quadratic out. */
    public static function quadOut (t :Float) :Float
    {
        return t * (2 - t);
    }

    /** Quadratic in and out. */
    public static function quadInOut (t :Float) :Float
    {
        return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
    }
	
    /** Quadratic out and in */
    static public function quadOutIn(t:Float):Float 
    {
        return (t < 0.5) ? -0.5 * (t = (t * 2)) * (t - 2) : 0.5 * (t = (t * 2 - 1)) * t + 0.5;
    }

    /** Cubic in. */
    public static function cubeIn (t :Float) :Float
    {
        return t * t * t;
    }

    /** Cubic out. */
    public static function cubeOut (t :Float) :Float
    {
        return 1 + (--t) * t * t;
    }

    /** Cubic in and out. */
    public static function cubeInOut (t :Float) :Float
    {
        return t <= .5 ? t * t * t * 4 : 1 + (--t) * t * t * 4;
    }

    /** Cubic out and in. */
    static public function cubeOutIn(t:Float):Float 
    {
        return 0.5 * ((t = t * 2 - 1) * t * t + 1);
    }

    /** Quartic in. */
    public static function quartIn (t :Float) :Float
    {
        return t * t * t * t;
    }

    /** Quartic out. */
    public static function quartOut (t :Float) :Float
    {
        return 1 - (--t) * t * t * t;
    }

    /** Quartic in and out. */
    public static function quartInOut (t :Float) :Float
    {
        return t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
    }
	
    /** Quartic out and in */
    static public function quartOutIn(t:Float):Float 
    {
        return (t < 0.5) ? -0.5 * (t = t * 2 - 1) * t * t * t + 0.5	: 0.5 * (t = t * 2 - 1) * t * t * t + 0.5;
    }

    /** Quintic in. */
    public static function quintIn (t :Float) :Float
    {
        return t * t * t * t * t;
    }

    /** Quintic out. */
    public static function quintOut (t :Float) :Float
    {
        return (t = t - 1) * t * t * t * t + 1;
    }

    /** Quintic in and out. */
    public static function quintInOut (t :Float) :Float
    {
        return ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
    }

    /** Quintic out and in. */
    static public function quintOutIn(t:Float):Float 
    {
        return 0.5 * ((t = t * 2 - 1) * t * t * t * t + 1);
    }

    /** Sine in. */
    public static function sineIn (t :Float) :Float
    {
        return 1 - Math.cos(PIhalf * t);
    }

    /** Sine out. */
    public static function sineOut (t :Float) :Float
    {
        return Math.sin(PIhalf * t);
    }

    /** Sine in and out. */
    public static function sineInOut (t :Float) :Float
    {
        return .5 - Math.cos(PI * t) / 2;
    }

	/** Sine out and in. */
    static public function sineOutIn(t:Float):Float {
        if (t == 0) return 0
        else if (t == 1) return 1
        else return (t < 0.5) ? 0.5 * Math.sin((t * 2) * PIhalf) : -0.5 * Math.cos((t * 2 - 1) * PIhalf) + 1;
    }

    /** Bounce in. */
    public static function bounceIn (t :Float) :Float
    {
        t = 1 - t;
        if (t < B1) return 1 - 7.5625 * t * t;
        if (t < B2) return 1 - (7.5625 * (t - B3) * (t - B3) + .75);
        if (t < B4) return 1 - (7.5625 * (t - B5) * (t - B5) + .9375);
        return 1 - (7.5625 * (t - B6) * (t - B6) + .984375);
    }

    /** Bounce out. */
    public static function bounceOut (t :Float) :Float
    {
        if (t < B1) return 7.5625 * t * t;
        if (t < B2) return 7.5625 * (t - B3) * (t - B3) + .75;
        if (t < B4) return 7.5625 * (t - B5) * (t - B5) + .9375;
        return 7.5625 * (t - B6) * (t - B6) + .984375;
    }

    /** Bounce in and out. */
    public static function bounceInOut (t :Float) :Float
    {
        if (t < .5) {
            t = 1 - t * 2;
            if (t < B1) return (1 - 7.5625 * t * t) / 2;
            if (t < B2) return (1 - (7.5625 * (t - B3) * (t - B3) + .75)) / 2;
            if (t < B4) return (1 - (7.5625 * (t - B5) * (t - B5) + .9375)) / 2;
            return (1 - (7.5625 * (t - B6) * (t - B6) + .984375)) / 2;
        }
        t = t * 2 - 1;
        if (t < B1) return (7.5625 * t * t) / 2 + .5;
        if (t < B2) return (7.5625 * (t - B3) * (t - B3) + .75) / 2 + .5;
        if (t < B4) return (7.5625 * (t - B5) * (t - B5) + .9375) / 2 + .5;
        return (7.5625 * (t - B6) * (t - B6) + .984375) / 2 + .5;
    }

    /** Circle in. */
    public static function circIn (t :Float) :Float
    {
        return 1 - Math.sqrt(1 - t * t);
    }

    /** Circle out. */
    public static function circOut (t :Float) :Float
    {
        --t;
        return Math.sqrt(1 - t * t);
    }

    /** Circle in and out. */
    public static function circInOut (t :Float) :Float
    {
        return t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
    }

    /** Circle out and in. */
    static public function circOutIn(t:Float):Float
    {
        return (t < 0.5) ? 0.5 * Math.sqrt(1 - (t = t * 2 - 1) * t) : -0.5 * ((Math.sqrt(1 - (t = t * 2 - 1) * t) - 1) - 1);
    }

    /** Exponential in. */
    public static function expoIn (t :Float) :Float
    {
        return Math.pow(2, 10 * (t - 1));
    }

    /** Exponential out. */
    public static function expoOut (t :Float) :Float
    {
        return -Math.pow(2, -10 * t) + 1;
    }

    /** Exponential in and out. */
    public static function expoInOut (t :Float) :Float
    {
        return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
    }

    /** Exponential out and in. */
    static public function expoOutIn(t:Float):Float 
    {
        return (t < 0.5) ? 0.5 * (1 - Math.pow(2, -20 * t)) : (t == 0.5) ?  0.5 :  0.5 * (Math.pow(2, 20 * (t - 1)) + 1);
    }

    /** Back in. */
    public static function backIn (t :Float) :Float
    {
        return t * t * (2.70158 * t - 1.70158);
    }

    /** Back out. */
    public static function backOut (t :Float) :Float
    {
        return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
    }

    /** Back in and out. */
    public static function backInOut (t :Float) :Float
    {
        t *= 2;
        if (t < 1) return t * t * (2.70158 * t - 1.70158) / 2;
        t -= 2;
        return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + .5;
    }

    /** Elastic in. */
    public static function elasticIn (t :Float) :Float
    {
        return -(ELASTIC_AMPLITUDE * Math.pow(2, 10 * (t -= 1)) * Math.sin( (t - (ELASTIC_PERIOD / PI2 * Math.asin(1 / ELASTIC_AMPLITUDE))) * PI2 / ELASTIC_PERIOD));
    }

    /** Elastic out. */
    public static function elasticOut (t :Float) :Float
    {
        return (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / PI2 * Math.asin(1 / ELASTIC_AMPLITUDE))) * PI2 / ELASTIC_PERIOD) + 1);
    }

    /** Elastic in and out. */
    public static function elasticInOut (t :Float) :Float
    {
        if (t < 0.5) {
            return -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * PI2 / ELASTIC_PERIOD));
        }
        return Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * PI2 / ELASTIC_PERIOD) * 0.5 + 1;
    }

    private static inline var PIhalf :Float = FMath.PI / 2;
    private static inline var PI :Float = FMath.PI;
    private static inline var PI2 :Float = FMath.PI * 2;
    private static inline var B1 :Float = 1 / 2.75;
    private static inline var B2 :Float = 2 / 2.75;
    private static inline var B3 :Float = 1.5 / 2.75;
    private static inline var B4 :Float = 2.5 / 2.75;
    private static inline var B5 :Float = 2.25 / 2.75;
    private static inline var B6 :Float = 2.625 / 2.75;
    private static inline var ELASTIC_AMPLITUDE :Float = 1;
    private static inline var ELASTIC_PERIOD :Float = 0.4;
}
