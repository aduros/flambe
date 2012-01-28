//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.animation.Property;
import flambe.util.Disposable;

interface Playback
    implements Disposable
{
    /**
     * The volume of the sound being played, between 0 and 1 (inclusive).
     */
    var volume (default, null) :PFloat;

    var paused (isPaused, setPaused) :Bool;

    /**
     * The current playback position in milliseconds.
     */
    var position (getPosition, null) :Float;

    /**
     * The sound being played.
     */
    var sound (getSound, null) :Sound;
}
