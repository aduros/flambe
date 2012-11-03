//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

/**
 * A 2D matrix.
 *
 * <pre>
 * [ m00 m01 m02 ]
 * [ m10 m11 m12 ]
 * [  0   0   1  ]
 * </pre>
 */
class Matrix
{
    public var m00 :Float;
    public var m01 :Float;
    public var m02 :Float;
    public var m10 :Float;
    public var m11 :Float;
    public var m12 :Float;

    public function new ()
    {
        identity();
    }

    public function set (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        this.m00 = m00; this.m01 = m01; this.m02 = m02;
        this.m10 = m10; this.m11 = m11; this.m12 = m12;
    }

    public function identity ()
    {
        set(1, 0, 0, 1, 0, 0);
    }

    public function compose (x :Float, y :Float, scaleX :Float, scaleY :Float, rotation :Float)
    {
        var sin = Math.sin(rotation);
        var cos = Math.cos(rotation);
        set(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, x, y);
    }

    public function translate (x :Float, y :Float)
    {
        m02 += m00*x + m01*y;
        m12 += m11*y + m10*x;
    }

    public function scale (x :Float, y :Float)
    {
        m00 *= x;
        m10 *= x;
        m01 *= y;
        m11 *= y;
    }

    public function rotate (rotation :Float)
    {
        var sin = Math.sin(rotation);
        var cos = Math.cos(rotation);

        var t00 = m00*cos + m01*sin;
        var t01 = -m00*sin + m01*cos;
        m00 = t00;
        m01 = t01;

        var t10 = m11*sin + m10*cos;
        var t11 = m11*cos - m10*sin;
        m10 = t10;
        m11 = t11;
    }

    public function transform (x :Float, y :Float, ?result :Point) :Point
    {
        if (result == null) {
            result = new Point();
        }
        result.x = x*m00 + y*m01 + m02;
        result.y = x*m10 + y*m11 + m12;
        return result;
    }

    /**
     * Calculate the determinant of this matrix.
     */
    public function determinant () :Float
    {
        return m00*m11 - m01*m10;
    }

    /**
     * Transforms a point by the inverse of this matrix, or return false if this matrix is not
     * invertible.
     */
    public function inverseTransform (x :Float, y :Float, result :Point) :Bool
    {
        var det = determinant();
        if (det == 0) {
            return false;
        }
        x -= m02;
        y -= m12;
        result.x = (x*m11 - y*m01) / det;
        result.y = (y*m00 - x*m10) / det;
        return true;
    }

    public static function multiply (lhs :Matrix, rhs :Matrix, ?result :Matrix) :Matrix
    {
        if (result == null) {
            result = new Matrix();
        }

        // First row
        var a = lhs.m00*rhs.m00 + lhs.m01*rhs.m10;
        var b = lhs.m00*rhs.m01 + lhs.m01*rhs.m11;
        var c = lhs.m00*rhs.m02 + lhs.m01*rhs.m12 + lhs.m02;
        result.m00 = a;
        result.m01 = b;
        result.m02 = c;

        // Second row
        a = lhs.m10*rhs.m00 + lhs.m11*rhs.m10;
        b = lhs.m10*rhs.m01 + lhs.m11*rhs.m11;
        c = lhs.m10*rhs.m02 + lhs.m11*rhs.m12 + lhs.m12;
        result.m10 = a;
        result.m11 = b;
        result.m12 = c;

        return result;
    }

    public function copyFrom (source :Matrix)
    {
        set(source.m00, source.m10, source.m01, source.m11, source.m02, source.m12);
    }

    /**
     * Creates a copy of this matrix.
     */
    public function clone ()
    {
        var clone = new Matrix();
        clone.copyFrom(this);
        return clone;
    }

#if debug
    public function toString () :String
    {
        return m00 + " " + m01 + " " + m02 + " \\ " +
            m10 + " " + m11 + " " + m12;
    }
#end
}
