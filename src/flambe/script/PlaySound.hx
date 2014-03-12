//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.sound.Sound;
import flambe.sound.Playback;

/**
 * An action that plays a sound and waits for it to complete.
 *
 * ```haxe
 * script.run(new Sequence([
 *     // Play a sound
 *     new PlaySound(sound1),
 *
 *     // Then wait 2 seconds
 *     new Delay(2),
 *
 *     // Then play another sound
 *     new PlaySound(sound2),
 * ]));
 * ```
 */
class PlaySound
    implements Action
{
    /**
     * @param sound The sound to play.
     * @param volume The volume to pass to `Sound.play`.
     */
    public function new (sound :Sound, ?volume :Float = 1.0)
    {
        _sound = sound;
        _volume = volume;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        if (_playback == null) {
            _playback = _sound.play(_volume);
        }
        if (_playback.complete._) {
            _playback = null;
            return 0; // Finished
        }
        return -1; // Keep waiting
    }

    private var _sound :Sound;
    private var _volume :Float;
    private var _playback :Playback = null;
}
