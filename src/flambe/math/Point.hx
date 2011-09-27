//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

class Point
{
    public var x :Float;
    public var y :Float;

    public function new (x :Float = 0.0, y :Float = 0.0)
    {
        this.x = x;
        this.y = y;
    }

    public function normalize ()
    {
        var m = magnitude();
        x /= m;
        y /= m;
    }

    public function dot (x :Float, y :Float) :Float
    {
        return this.x*x + this.y*y;
    }

    public function multiply (n :Float)
    {
        x *= n;
        y *= n;
    }

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
