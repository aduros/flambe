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
		pitch = 0;
		roll = 0;
		azimuth = 0;
	}

    public function _internal_update(pitch:Float, roll:Float, azimuth:Float):Void
    {
		this.pitch = pitch;
		this.roll = roll;
		this.azimuth = azimuth;
    }

    /**
     *
     */
    public var pitch(default, null):Float;
    /**
     *
     */
    public var roll(default, null):Float;
    /**
     * Relative to the heading of the device at page load, NOT magnetic or true north.
     * Does not currently take into account changes in window orientation; need to determine
     * if that would be a better implementation.
     */
    public var azimuth(default, null):Float;

}
