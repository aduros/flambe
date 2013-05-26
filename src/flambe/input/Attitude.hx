//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

class Attitude
{
    public var pitch (default, null) :Float;
    public var roll (default, null) :Float;
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
