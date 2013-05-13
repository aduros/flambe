//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Value;

/**
 * TODO: Document.
 */
class AccelerometerOrientation
{
    /**
     *
     */
    public var pitch(default, null) :Float;

    /**
     *
     */
    public var roll (default, null) :Float;

    /**
     * Relative to the heading of the device at page load, NOT magnetic or true north.
     * Does not currently take into account changes in window orientation; need to determine
     * if that would be a better implementation.
     */
    public var azimuth(default, null):Float;
    /* TODO: Add this, and make relative to game orientation. */
    //public var compassHeading(default, null):Float;
    /* TODO: Add this. */
    //public var compassAccuracy(default, null):Float;

    /** @private */ public function new ()
    {
        _internal_update(0, 0, 0);
    }

    /** @private */ public function _internal_update (pitch :Float, roll :Float, azimuth :Float)
    {
        this.pitch = pitch;
        this.roll = roll;
        this.azimuth = azimuth;
    }
}
