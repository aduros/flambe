//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

interface Keyboard
{
    /**
     * True if the environment has a keyboard.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Emitted when a physical key is pressed down.
     */
    var down (default, null) :Signal1<KeyEvent>;

    /**
     * Emitted when a physical key is released.
     */
    var up (default, null) :Signal1<KeyEvent>;

    /**
     * Returns true if a key with given charCode is being held down.
     */
    function isDown (charCode :Int) :Bool;
}
