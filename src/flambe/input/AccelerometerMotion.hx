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
		x = 0;
		y = 0;
		z = 0;
	}

    public function _internal_update(x:Float, y:Float, z:Float):Void
    {
		this.x = x;
		this.y = y;
		this.z = z;
    }

    public var x(default, null):Float;//TODO
    public var y(default, null):Float;//TODO
    public var z(default, null):Float;//TODO

}
