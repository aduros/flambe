//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Value;

/**
 * 
 */
class AccelerometerMotion
{
	public function new()
	{
		x = new Value<Float>(0);
		y = new Value<Float>(0);
		z = new Value<Float>(0);
	}

    public function update(x:Float, y:Float, z:Float):Void
    {
		this.x._ = x;
		this.y._ = y;
		this.z._ = z;
    }

    public var x(default, null):Value<Float>;//TODO
    public var y(default, null):Value<Float>;//TODO
    public var z(default, null):Value<Float>;//TODO

}
