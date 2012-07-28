//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

/**
 * Functions related to the environment's mouse.
 */
interface Mouse
{
    /**
     * True if the environment has a mouse.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Emitted when a mouse button is pressed down.
     */
    var down (default, null) :Signal1<MouseEvent>;

    /**
     * Emitted when the mouse cursor is moved while over the stage.
     */
    var move (default, null) :Signal1<MouseEvent>;

    /**
     * Emitted when a mouse button is released.
     */
    var up (default, null) :Signal1<MouseEvent>;

    /**
     * The last recorded X coordinate of the mouse.
     */
    var x (getX, null) :Float;

    /**
     * The last recorded Y coordinate of the mouse.
     */
    var y (getY, null) :Float;

    /**
     * The style of the mouse cursor.
     */
    var cursor (getCursor, setCursor) :MouseCursor;

    /**
     * @returns True if the given button is currently being held down.
     */
    function isDown (button :MouseButton) :Bool;
}
