//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.display.Orientation;
import flambe.util.Signal0;
import flambe.util.Value;

/**
 * Functions related to the environment's display viewport.
 */
interface StageSystem
{
    /**
     * The width of the stage viewport, in pixels.
     */
    var width (get, null) :Int;

    /**
     * The height of the stage viewport, in pixels.
     */
    var height (get, null) :Int;

    /**
     * The current screen orientation, or a wrapped null value if the environment doesn't support
     * multiple orientations.
     */
    var orientation (default, null) :Value<Orientation>;

    /**
     * True if the stage is currently fullscreen.
     */
    var fullscreen (default, null) :Value<Bool>;

    /**
     * Whether the stage may change its fullscreen state. False if the stage is fullscreen and can't
     * go into windowed mode, or vise versa.
     */
    var fullscreenSupported (get, null) :Bool;

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

    /**
     * Request that fullscreen be enabled or disabled. No effect if changing fullscreen is not
     * supported.
     */
    function requestFullscreen (enable :Bool = true) :Void;
}
