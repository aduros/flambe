//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.asset.Asset;

/**
 * A loaded sound file.
 */
interface Sound extends Asset
{
    /**
     * The length of the sound in seconds.
     */
    var duration (get, null) :Float;

    /**
     * Plays the sound once, suitable for one-shot sound effects.
     *
     * @param volume The playback volume between 0 (silence) and 1 (full volume). Defaults to 1.
     * @param offset An optional offset (seconds) from the start of the sound
     * @param duration Duration (seconds) to play. Set to zero (default) to play up to the duration of the sound.
     * @returns A playback that can be used to control the sound.
     */
    function play (volume :Float = 1.0, ?offset:Float=0, ?duration:Float=0) :Playback;
	
    /**
     * Loops the sound forever, suitable for background music.
     *
     * @param volume The playback volume between 0 (silence) and 1 (full volume). Defaults to 1.
     * @param offset An optional offset (seconds) from the start of the sound to begin the loop at
     * @param duration Duration (seconds) of the loop. Set to zero (default) to play up to the duration of the sound.
     * @returns A playback that can be used to control the sound.
     */
    function loop (volume :Float = 1.0, ?offset:Float=0, ?duration:Float=0) :Playback;
}
