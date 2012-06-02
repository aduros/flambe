//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.util.Signal0;

/**
 * Functions related to the environment's display viewport.
 */
interface Stage
{
    /**
     * The width of the stage viewport, in pixels.
     */
    var width (getWidth, null) :Int;

    /**
     * The height of the stage viewport, in pixels.
     */
    var height (getHeight, null) :Int;

    /**
     * Emitted after the stage size changes, such as when the window is resized or the device is
     * rotated.
     */
    var resize (default, null) :Signal0;

    /**
     * Request to lock the orientation, so that rotating the device will not adjust the screen. Has
     * no effect if the environment doesn't support orientation locking.
     * @param orient The orientation to lock to.
     */
    function lockOrientation (orient :Orientation) :Void;

    /**
     * Request to unlock the orientation, so that rotating the device will adjust the screen. Has no
     * effect if the environment doesn't support orientation locking.
     */
    function unlockOrientation () :Void;

    /**
     * Request that the stage be resized to a certain size.
     */
    function requestResize (width :Int, height :Int) :Void;
}
