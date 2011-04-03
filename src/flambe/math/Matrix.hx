package flambe.math;

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

    public function identity ()
    {
        m00 = 1;
        m01 = 0;
        m02 = 0;
        m10 = 0;
        m11 = 1;
        m12 = 0;
    }

    public function copyFrom (source :Matrix)
    {
        m00 = source.m00;
        m01 = source.m01;
        m02 = source.m02;
        m10 = source.m10;
        m11 = source.m11;
        m12 = source.m12;
    }

    public function translate (x :Float, y :Float)
    {
        m02 += m00*x + m01*y;
        m12 += m11*y + m10*x;
    }

    public function scale (x :Float, y :Float)
    {
        m00 *= x;
        m11 *= y;
        m01 *= y;
        m10 *= x;
    }

    public function rotate (angle :Float)
    {
        var sin = Math.sin(angle);
        var cos = Math.cos(angle);

        var c00 = m00*cos + m01*sin;
        var c01 = -m00*sin + m01*cos;
        var c10 = m11*sin + m10*cos;
        var c11 = m11*cos - m10*sin;

        m00 = c00;
        m01 = c01;
        m10 = c10;
        m11 = c11;
    }

    public function getDeterminant ()
    {
        return m00*m11 - m01*m10;
    }

    public function inverseTransformX (x :Float, y :Float) :Float
    {
        x -= m02;
        y -= m12;
        var det = getDeterminant();
        if (det == 0) {
            return Math.NaN;
        }
        return (x*m11 - y*m01) / det;
    }

    public function inverseTransformY (x :Float, y :Float) :Float
    {
        x -= m02;
        y -= m12;
        var det = getDeterminant();
        if (det == 0) {
            return Math.NaN;
        }
        return (y*m00 - x*m10) / det;
    }

    public function inverseTransformPoint (x :Float, y :Float) :Point
    {
        return new Point(inverseTransformX(x, y), inverseTransformY(x, y));
    }
}
