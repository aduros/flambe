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
		pitch = new Value<Float>(0);
		roll = new Value<Float>(0);
		azimuth = new Value<Float>(0);
	}

    public function update(pitch:Float, roll:Float, azimuth:Float):Void
    {
		this.pitch._ = pitch;
		this.roll._ = roll;
		this.azimuth._ = azimuth;
    }

    /**
     *
     */
    public var pitch(default, null):Value<Float>;
    /**
     *
     */
    public var roll(default, null):Value<Float>;
    /**
     * Relative to the heading of the device at page load, NOT magnetic or true north.
     * Does not currently take into account changes in window orientation; need to determine
     * if that would be a better implementation.
     */
    public var azimuth(default, null):Value<Float>;

}
