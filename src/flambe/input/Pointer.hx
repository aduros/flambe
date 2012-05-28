//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

/**
 * Functions related to the environment's pointing device. On desktop computers, this is a mouse. On
 * touch screens, it's a finger.
 */
interface Pointer
{
    /**
     * True if the environment has a pointing device.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Emitted when the pointing device is pressed down (when the mouse button is held or a finger
     * is pressed to the screen).
     */
    var down (default, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointing device moves while over the stage.
     */
    var move (default, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointing device is released (when the mouse button is released or the finger
     * is lifted is lifted from the screen).
     */
    var up (default, null) :Signal1<PointerEvent>;

    /**
     * The last recorded X coordinate of the pointer.
     */
    var x (getX, null) :Float;

    /**
     * The last recorded Y coordinate of the pointer;
     */
    var y (getY, null) :Float;

    /**
     * True if the pointer is currently pressed down.
     */
    function isDown () :Bool;
}
