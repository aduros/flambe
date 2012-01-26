//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

interface Playback
{
    /**
     * The volume of the sound being played, between 0 and 1 (inclusive).
     */
    // TODO(bruno): Make volume an animatable PFloat
    var volume (getVolume, setVolume) :Float;

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
