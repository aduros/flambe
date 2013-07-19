//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.animation.AnimatedFloat;
import flambe.util.Disposable;

/**
 * Represents a currently playing sound.
 */
interface Playback extends Disposable
{
    /**
     * The volume of the sound being played, between 0 and 1 (inclusive).
     */
    var volume (default, null) :AnimatedFloat;

    /**
     * Whether the playback is currently paused. Playbacks are automatically paused while the app is
     * hidden, such as when minimized or placed in a background browser tab.
     */
    var paused (get, set) :Bool;

    /**
     * True if the playback has finished playing, or has been disposed. Looping playbacks will never
     * end naturally, and return true only after being disposed.
     */
    var ended (get, null) :Bool;

    /**
     * The current playback position in seconds.
     */
    var position (get, null) :Float;

    /**
     * The sound being played.
     */
    var sound (get, null) :Sound;
}
