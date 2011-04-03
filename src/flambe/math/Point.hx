package flambe.math;

class Point
{
    public var x :Float;
    public var y :Float;

    public function new (?x = 0.0, ?y = 0.0)
    {
        this.x = x;
        this.y = y;
    }
}
