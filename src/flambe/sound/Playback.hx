//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.animation.AnimatedFloat;
import flambe.util.Disposable;

/**
 * Represents a currently playing sound.
 */
interface Playback
    implements Disposable
{
    /**
     * The volume of the sound being played, between 0 and 1 (inclusive).
     */
    var volume (default, null) :AnimatedFloat;

    var paused (get_paused, set_paused) :Bool;

    /**
     * True if the playback has finished playing, or has been disposed. Looping playbacks will never
     * end naturally, and return true only after being disposed.
     */
    var ended (get_ended, null) :Bool;

    /**
     * The current playback position in seconds.
     */
    var position (get_position, null) :Float;

    /**
     * The sound being played.
     */
    var sound (get_sound, null) :Sound;
}
