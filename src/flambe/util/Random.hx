//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.math.FMath;

/**
 * A seedable, portable random number generator. Fast and random enough for games.
 * http://en.wikipedia.org/wiki/Linear_congruential_generator
 */
class Random
{
    /**
     * The original used seed. When seed is set, internal state will reset to give the ability 
     * to run the same sequence of random numbers again.
     */
    public var seed(get, set) :Int;

    public function new (?seed :Int)
    {
        this.seed = (seed != null) ? seed : Math.floor(Math.random() * FMath.INT_MAX);
    }

    /**
     * Returns an integer in [0, INT_MAX]
     */
    public function nextInt () :Int
    {
        // These constants borrowed from glibc
        // Force float multiplication here to avoid overflow in Flash (and keep parity with JS)
        _state = cast ((1103515245.0*_state + 12345) % FMath.INT_MAX);
        return _state;
    }

    /**
     * Returns a number in [0, 1]
     */
    public function nextFloat () :Float
    {
        return nextInt() / FMath.INT_MAX;
    }

    inline private function get_seed() :Int
    {
        return _seed;
    }

    inline private function set_seed(value :Int)
    {
        _seed = _state = value;
        return value;
    }

    private var _state :Int;
    private var _seed :Int;
}
