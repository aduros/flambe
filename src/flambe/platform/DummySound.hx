//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.sound.Playback;
import flambe.sound.Sound;

/**
 * An empty sound used in environments that don't support audio.
 */
class DummySound
    implements Sound
{
    public var duration (getDuration, null) :Float;

    public function new ()
    {
        _playback = new DummyPlayback(this);
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return _playback;
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return _playback;
    }

    public function getDuration () :Float
    {
        return 0;
    }

    public static function getInstance () :DummySound
    {
        if (_instance == null) {
            _instance = new DummySound();
        }
        return _instance;
    }

    private static var _instance :DummySound;

    private var _playback :DummyPlayback;
}

// This should be immutable too
class DummyPlayback
    implements Playback
{
    public var volume (getVolume, setVolume) :Float;
    public var paused (isPaused, setPaused) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :DummySound)
    {
        _sound = sound;
    }

    public function getVolume () :Float
    {
        return 0;
    }

    public function setVolume (volume :Float) :Float
    {
        return 0;
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    public function isPaused () :Bool
    {
        return true;
    }

    public function setPaused (paused :Bool) :Bool
    {
        return true;
    }

    public function getPosition () :Float
    {
        return 0;
    }

    private var _sound :DummySound;
}
