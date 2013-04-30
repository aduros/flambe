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

	}

    public function update(x:Float, y:Float, z:Float):Void
    {
		this.accelX._ = x;
		this.accelY._ = y;
		this.accelZ._ = z;
    }

    public var accelX(default, null):Value<Float>;//TODO
    public var accelY(default, null):Value<Float>;//TODO
    public var accelZ(default, null):Value<Float>;//TODO

}
