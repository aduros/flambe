//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.animation.AnimatedFloat;
import flambe.util.Disposable;
import flambe.util.Value;

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
     * Whether the playback has finished playing or has been disposed. Looping playbacks will never
     * complete naturally, and are complete only after being disposed.
     *
     * In environments that don't support audio, this will be true.
     *
     * Do not set this value! To pause the playback, set `paused`. To stop it completely, call
     * `dispose()`.
     */
    var complete (get, null) :Value<Bool>;

    /**
     * The current playback position in seconds.
     */
    var position (get, null) :Float;

    /**
     * The sound being played.
     */
    var sound (get, null) :Sound;
}
