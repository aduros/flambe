//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

#if flambe_air
import flash.display.StageOrientation;
import flash.display.StageAspectRatio;
#end
import nme.errors.Error;
import nme.events.ErrorEvent;
import nme.ui.Mouse;

import flambe.display.Orientation;

class NMEUtil
{
    /** Tries to guess if we're running on a mobile device. */
    inline public static function isMobile () :Bool
    {
    	#if mobile
    	return true;
    	#else
    	return false;
    	#end
        //return !Mouse.supportsCursor;
    }

    /** Extracts the best error-like message from a given value. */
    public static function getErrorMessage (error :Dynamic) :String
    {
        if (Std.is(error, Error)) {
            return Std.string (cast(error, Error));
        } else if (Std.is(error, ErrorEvent)) {
            return cast(error, ErrorEvent).text;
        } else {
            return error.toString();
        }
    }

#if flambe_air
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
