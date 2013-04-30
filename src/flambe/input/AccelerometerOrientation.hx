//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Value;

/**
 * 
 */
class AccelerometerOrientation
{
	public function new()
	{
		azimuth = new Value<Float>(0);
		pitch = new Value<Float>(0);
		roll = new Value<Float>(0);
	}

    public function update(pitch:Float, roll:Float, azimuth:Float):Void
    {
		this.pitch._ = pitch;
		this.roll._ = roll;
		this.azimuth._ = azimuth;
    }

    public var azimuth(default, null):Value<Float>;
    public var pitch(default, null):Value<Float>;
    public var roll(default, null):Value<Float>;

}
