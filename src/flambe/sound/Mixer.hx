//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.sound;

import flambe.math.FMath;
import flambe.platform.DummySound;
import flambe.util.Disposable;
import flambe.util.Value;

/**
 * An easy way to manage the lifecycle of multiple sounds. A handle is created from a source sound
 * using `createSound()`, and all handle playbacks will be stopped when the Mixer is disposed.
 */
class Mixer
    extends Component
{
    public function new ()
    {
        _sounds = [];
    }

    /**
     * Creates a sound handle from a source sound. Playbacks created using the handle will be
     * stopped when this Mixer is disposed.
     *
     * @param channels The maximum number of times this sound should be able to play at once.
     */
    public function createSound (source :Sound, channels :Int = FMath.INT_MAX) :Sound
    {
        var sound = new MixerSound(source, channels);
        _sounds.push(sound);
        return sound;
    }

    /**
     * Stop all the playbacks belonging to this Mixer.
     */
    public function stopAll ()
    {
        for (sound in _sounds) {
            sound.dispose();
        }
    }

    override public function onRemoved ()
    {
        stopAll();
        _sounds = [];
    }

    private var _sounds :Array<MixerSound>;
}

private class MixerSound
    implements Sound
    implements Disposable
{
    public var reloadCount (get, null) :Value<Int>;

    public var duration (get, null) :Float;

    public function new (source :Sound, channels :Int)
    {
        _source = source;
        _channels = channels;
        _playbacks = [];
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return playOrLoop(volume, false);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return playOrLoop(volume, true);
    }

    private function playOrLoop (volume :Float, loop :Bool) :Playback
    {
        var channel = findOpenChannel();
        if (channel < 0) {
            // No channels remaining, don't play anything
            return new DummyPlayback(this);
        }

        var playback = loop ? _source.loop(volume) : _source.play(volume);
        _playbacks[channel] = playback;
        return playback;
    }

    private function findOpenChannel () :Int
    {
        for (ii in 0..._channels) {
            var playback = _playbacks[ii];
            if (playback == null || playback.complete._) {
                return ii;
            }
        }
        return -1;
    }

    public function get_duration () :Float
    {
        return _source.duration;
    }

    public function get_reloadCount () :Value<Int>
    {
        return _source.reloadCount;
    }

    public function dispose ()
    {
        for (playback in _playbacks) {
            playback.dispose();
        }
        _playbacks = [];
    }

    private var _source :Sound;
    private var _channels :Int;
    private var _playbacks :Array<Playback>;
}
