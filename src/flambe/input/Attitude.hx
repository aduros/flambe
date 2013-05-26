//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * <p>Three angles that represent the device's attitude, one around each axis.</p>
 *
 * <p><img src="https://aduros.com/flambe/images/Axes.png"></p>
 */
class Attitude
{
    /**
     * <p>The angle in degrees around the X-axis; that is, how far the device is pitched forward or
     * backward.</p>
     *
     * <p><img src="https://aduros.com/flambe/images/Axes-Pitch.png"></p>
     */
    public var pitch (default, null) :Float;

    /**
     * <p>The angle in degrees around the Y-axis; that is, how far the device is rolled left or
     * right.</p>
     *
     * <p><img src="https://aduros.com/flambe/images/Axes-Roll.png"></p>
     */
    public var roll (default, null) :Float;

    /**
     * <p>The angle in degrees around the Z-axis.</p>
     *
     * <p><img src="https://aduros.com/flambe/images/Axes-Azimuth.png"></p>
     */
    public var azimuth (default, null) :Float;

    /** @private */ public function new ()
    {
        _internal_init(0, 0, 0);
    }

    /** @private */ public function _internal_init (pitch :Float, roll :Float, azimuth :Float)
    {
        this.pitch = pitch;
        this.roll = roll;
        this.azimuth = azimuth;
    }
}
