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
    public var volume (getVolume, setVolume) :Float;

    public var paused (isPaused, setPaused) :Bool;

    /**
     * The current playback position in milliseconds.
     */
    public var position (getPosition, null) :Float;

    /**
     * The sound being played.
     */
    public var sound (getSound, null) :Sound;

    public function getVolume () :Float;
    public function setVolume (volume :Float) :Float;

    public function isPaused () :Bool;
    public function setPaused (paused :Bool) :Bool;

    public function getPosition () :Float;

    public function getSound () :Sound;
}
