//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.util.Signal0;
import flambe.util.Signal1;

/**
 * Functions related to the environment's physical keyboard.
 */
interface KeyboardSystem
{
    /**
     * Whether the environment has a physical keyboard. Phones and tablets will generally return
     * false here.
     */
    var supported (get, null) :Bool;

    /**
     * Emitted when a key is pressed down.
     */
    var down (default, null) :Signal1<KeyboardEvent>;

    /**
     * Emitted when a key is released.
     */
    var up (default, null) :Signal1<KeyboardEvent>;

    /**
     * Emitted when a hardware back button is pressed. If no listeners are connected to this signal
     * when the back button is pressed, the platform's default action will be taken (which is
     * usually to close the app). Only supported on Android.
     */
    var backButton (default, null) :Signal0;

    /**
     * @returns True if the given key is currently being held down.
     */
    function isDown (key :Key) :Bool;
}
