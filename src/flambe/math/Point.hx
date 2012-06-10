//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

/**
 * A 2D point or vector.
 */
class Point
{
    public var x :Float;
    public var y :Float;

    public function new (x :Float = 0, y :Float = 0)
    {
        this.x = x;
        this.y = y;
    }

    /**
     * Normalize this vector, so that its new magnitude is 1.
     */
    public function normalize ()
    {
        var m = magnitude();
        x /= m;
        y /= m;
    }

    /**
     * @return The dot product of the two vectors.
     */
    public function dot (x :Float, y :Float) :Float
    {
        return this.x*x + this.y*y;
    }

    /**
     * Scales a vector's magnitude by a given value.
     */
    public function multiply (n :Float)
    {
        x *= n;
        y *= n;
    }

    /**
     * @return The magnitude (length) of this vector.
     */
    public function magnitude () :Float
    {
        return Math.sqrt(x*x + y*y);
    }

    public function clone () :Point
    {
        return new Point(x, y);
    }

#if debug
    public function toString () :String
    {
        return "(" + x + "," + y + ")";
    }
#end
}
