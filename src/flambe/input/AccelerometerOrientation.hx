//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.input.Accelerometer;

/**
 * TODO: Document.
 */
class AccelerometerOrientation
{

    /**
     * <p>Rotation, in degrees, of the window frame around its x-axis (left/right).</p>
     */
    public var roll (default, null) :Float;

    /**
     * <p>Rotation, in degrees, of the window frame around its y-axis (forward/back).</p>
     */
    public var pitch(default, null) :Float;
    /**
     * <p>The rotation, in degrees, of the device frame around its y-axis.</p>
     * <p>Relative to the heading of the device at page load, NOT magnetic or true north.</p>
     */
    public var azimuth(default, null):Float;
    /**
     * <p>A holder for accuracy of the compass data in degrees. <code>null</code> when not available.</p>
     */
    public var compassHeading(default, null):AccelerometerFloat;
    /**
     * <p>A holder for direction that is measured in degrees relative to magnetic north. <code>null</code> when not available.</p>
     * <p>TODO: Make relative to window frame.</p>
     */
    public var compassAccuracy(default, null):AccelerometerFloat;

    /** @private */ public function new ()
    {
        compassHeading = null;
        compassAccuracy = null;
        _internal_update(0, 0, 0);
    }

    /** @private */ public function _internal_update_heading (value:Float):Void
    {
        if (compassHeading == null)
        {
            compassHeading = new AccelerometerFloat();
        }

        compassHeading._internal_set_value(value);
    }

    /** @private */ public function _internal_update_accuracy (value:Float):Void
    {
        if (compassAccuracy == null)
        {
            compassAccuracy = new AccelerometerFloat();
        }

        compassAccuracy._internal_set_value(value);
    }

    /** @private */ public function _internal_update (pitch :Float, roll :Float, azimuth :Float):Void
    {
        this.pitch = pitch;
        this.roll = roll;
        this.azimuth = azimuth;
    }
}

