//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

interface Input
{
    /**
     * Emitted when the pointing device (the mouse or a single finger) is pressed.
     */
    var pointerDown (default, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointing device (the mouse or a single finger) is moved.
     */
    var pointerMove (default, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointing device (the mouse or a single finger) is lifted.
     */
    var pointerUp (default, null) :Signal1<PointerEvent>;

    /**
     * Returns true if the pointing device (the mouse or a single finger) is currently pressed.
     */
    function isPointerDown () :Bool;
    var pointerX (default, null) :Float;
    var pointerY (default, null) :Float;

    /**
     * Emitted when a physical key is pressed down.
     */
    var keyDown (default, null) :Signal1<KeyEvent>;

    /**
     * Emitted when a physical key is released.
     */
    var keyUp (default, null) :Signal1<KeyEvent>;

    /**
     * Returns true if a key with given charCode is being held down.
     */
    function isKeyDown (charCode :Int) :Bool;
}
