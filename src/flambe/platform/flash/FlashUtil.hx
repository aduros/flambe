//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.ui.Mouse;

class FlashUtil
{
    /** Tries to guess if we're running on a mobile device. */
    public static function isMobile ()
    {
        // Look up Mouse.supportsCursor reflectively, because it's not worth depending on Flash 10.1
        return Reflect.hasField(Mouse, "supportsCursor")
            && !Reflect.field(Mouse, "supportsCursor");
    }

}
