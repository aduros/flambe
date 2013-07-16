//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

#if air
import flash.display.StageOrientation;
import flash.display.StageAspectRatio;
#end
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.geom.Matrix;
import flash.ui.Mouse;

import flambe.display.Orientation;

class FlashUtil
{
    /** Tries to guess if we're running on a mobile device. */
    inline public static function isMobile () :Bool
    {
        return !Mouse.supportsCursor;
    }

    /** Extracts the best error-like message from a given value. */
    public static function getErrorMessage (error :Dynamic) :String
    {
        if (Std.is(error, Error)) {
            return cast(error, Error).message;
        } else if (Std.is(error, ErrorEvent)) {
            return cast(error, ErrorEvent).text;
        } else {
            return error.toString();
        }
    }

#if air
    /** Convert an AIR stage orientation to a Flambe orientation. */
    public static function orientation (orient :StageOrientation) :Orientation
    {
        switch (orient) {
            case DEFAULT, UPSIDE_DOWN: return Portrait;
            case ROTATED_LEFT, ROTATED_RIGHT: return Landscape;
            default: return null;
        }
    }

    /** Convert a Flambe orientation to an AIR aspect ratio. */
    public static function aspectRatio (orient :Orientation) :StageAspectRatio
    {
        switch (orient) {
            case Portrait: return PORTRAIT;
            case Landscape: return LANDSCAPE;
        }
    }
#end
}
