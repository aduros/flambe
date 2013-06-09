//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.input.TouchPoint;
import flambe.util.Signal1;

/**
 * Functions related to the environment's touch screen.
 */
interface TouchSystem
{
    /**
     * True if the environment has a touch screen.
     */
    var supported (get, null) :Bool;

    /**
     * The maximum number of touch points that can be detected at once.
     */
    var maxPoints (get, null) :Int;

    /**
     * Emits a new TouchPoint when a finger presses down on the screen.
     */
    var down (default, null) :Signal1<TouchPoint>;

    /**
     * Emits the modified TouchPoint when a finger changes position.
     */
    var move (default, null) :Signal1<TouchPoint>;

    /**
     * Emits the removed TouchPoint when a finger is raised from the screen.
     */
    var up (default, null) :Signal1<TouchPoint>;

    /**
     * The touch points currently pressed to the screen.
     */
    var points (get, null) :Array<TouchPoint>;
}
