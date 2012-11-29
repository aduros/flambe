//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

/**
 * A 2D rectangle.
 */
class Rectangle
{
    public var x :Float;
    public var y :Float;
    public var width :Float;
    public var height :Float;

    public function new (x :Float = 0, y :Float = 0, width :Float = 0, height :Float = 0)
    {
        set(x, y, width, height);
    }

    public function set (x :Float, y :Float, width :Float, height :Float)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    /**
     * Returns true if this rectangle contains the given point.
     */
    public function contains (x :Float, y :Float) :Bool
    {
        x -= this.x;
        y -= this.y;
        return x >= 0 && y >= 0 && x <= width && y <= height;
    }

    /**
     * Creates a copy of this rectangle.
     */
    public function clone (?result :Rectangle) :Rectangle
    {
        if (result == null) {
            result = new Rectangle();
        }
        result.set(x, y, width, height);
        return result;
    }

    #if debug @:keep #end public function toString () :String
    {
        return "(" + x + "," + y + " " + width + "x" + height + ")";
    }
}
