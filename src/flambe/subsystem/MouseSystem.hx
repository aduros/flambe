//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.input.MouseButton;
import flambe.input.MouseCursor;
import flambe.input.MouseEvent;
import flambe.util.Signal1;

/**
 * Functions related to the environment's mouse.
 */
interface MouseSystem
{
    /**
     * True if the environment has a mouse.
     */
    var supported (get, null) :Bool;

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
     * A velocity emitted when the mouse wheel or trackpad is scrolled. A positive value is an
     * upward scroll, negative is a downward scroll. Typically, each scroll wheel "click" equates to
     * 1 velocity.
     */
    var scroll (default, null) :Signal1<Float>;

    /**
     * The last recorded X coordinate of the mouse.
     */
    var x (get, null) :Float;

    /**
     * The last recorded Y coordinate of the mouse.
     */
    var y (get, null) :Float;

    /**
     * The style of the mouse cursor.
     */
    var cursor (get, set) :MouseCursor;

    /**
     * @returns True if the given button is currently being held down.
     */
    function isDown (button :MouseButton) :Bool;
}
