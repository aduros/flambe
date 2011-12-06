//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.ui.Mouse;

class FlashUtil
{
    /** Tries to guess if we're running on a mobile device. */
    public static function isMobile () :Bool
    {
        // Look up Mouse.supportsCursor reflectively, because it's not worth depending on Flash 10.1
        return Reflect.hasField(Mouse, "supportsCursor")
            && !Reflect.field(Mouse, "supportsCursor");
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
}
