//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

class Jitter
    implements Behavior
{
    public var base (default, null) :Float;
    public var strength (default, null) :Float;

    public function new (base :Float, strength :Float)
    {
        this.base = base;
        this.strength = strength;
    }

    public function update (dt :Float) :Float
    {
        return base + 2*Math.random()*strength - strength;
    }

    public function isComplete () :Bool
    {
        return false;
    }
}
