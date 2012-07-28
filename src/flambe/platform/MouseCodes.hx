//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.MouseButton;

/**
 * Mouse button codes used internally.
 */
class MouseCodes
{
    public static inline var LEFT = 0;
    public static inline var MIDDLE = 1;
    public static inline var RIGHT = 2;

    public static function toButton (buttonCode :Int) :MouseButton
    {
        switch (buttonCode) {
            case LEFT: return Left;
            case MIDDLE: return Middle;
            case RIGHT: return Right;
        }

        return Unknown(buttonCode);
    }

    public static function toButtonCode (button :MouseButton) :Int
    {
        switch (button) {
            case Left: return LEFT;
            case Middle: return MIDDLE;
            case Right: return RIGHT;

            case Unknown(buttonCode): return buttonCode;
        }
    }
}
