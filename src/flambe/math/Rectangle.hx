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
        // A little more complicated than usual due to proper handling of negative widths/heights

        x -= this.x;
        if (width >= 0) {
            if (x < 0 || x > width) {
                return false;
            }
        } else if (x > 0 || x < width) {
            return false;
        }

        y -= this.y;
        if (height >= 0) {
            if (y < 0 || y > height) {
                return false;
            }
        } else if (y > 0 || y < height) {
            return false;
        }

        return true;
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

    public function equals (other :Rectangle) :Bool
    {
        return x == other.x && y == other.y && width == other.width && height == other.height;
    }

    #if debug @:keep #end public function toString () :String
    {
        return "(" + x + "," + y + " " + width + "x" + height + ")";
    }
}
