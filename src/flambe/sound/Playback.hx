//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.animation.AnimatedFloat;
import flambe.util.Disposable;

interface Playback
    implements Disposable
{
    /**
     * The volume of the sound being played, between 0 and 1 (inclusive).
     */
    var volume (default, null) :AnimatedFloat;

    var paused (isPaused, setPaused) :Bool;

    /**
     * True if the playback has finished playing, or has been disposed. Looping playbacks will never
     * end naturally, and return true only after being disposed.
     */
    var ended (isEnded, null) :Bool;

    /**
     * The current playback position in milliseconds.
     */
    var position (getPosition, null) :Float;

    /**
     * The sound being played.
     */
    var sound (getSound, null) :Sound;
}
