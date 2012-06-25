//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

/**
 * Functions related to the environment's physical keyboard.
 */
interface Keyboard
{
    /**
     * True if the environment has a physical keyboard. Phones and tablets will generally return
     * false here.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Emitted when a key is pressed down.
     */
    var down (default, null) :Signal1<KeyboardEvent>;

    /**
     * Emitted when a key is released.
     */
    var up (default, null) :Signal1<KeyboardEvent>;

    /**
     * @returns True if a key with the given keyCode is currently being held down.
     */
    function isDown (keyCode :Int) :Bool;
}
