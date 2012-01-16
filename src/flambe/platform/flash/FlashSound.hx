//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.media.SoundChannel;
import flash.media.SoundTransform;

import flambe.sound.Sound;
import flambe.sound.Playback;
import flambe.math.FMath;

class FlashSound
    implements Sound
{
    public var duration (getDuration, null) :Float;
    public var fms :flash.media.Sound;

    public function new (sound :flash.media.Sound)
    {
        this.fms = sound;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return new FlashPlayback(this, volume, 0);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return new FlashPlayback(this, volume, FMath.INT_MAX);
    }

    public function getDuration () :Float
    {
        return fms.length;
    }
}

class FlashPlayback
    implements Playback
{
    public var volume (getVolume, setVolume) :Float;
    public var paused (isPaused, setPaused) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :FlashSound, volume :Float, loops :Int)
    {
        _sound = sound;
        _pausePosition = -1;
        _channel = sound.fms.play(0, loops, new SoundTransform(volume));
        _loops = loops;
    }

    public function getVolume () :Float
    {
        return _channel.soundTransform.volume;
    }

    public function setVolume (volume :Float) :Float
    {
        var soundTransform = _channel.soundTransform;
        soundTransform.volume = volume;
        _channel.soundTransform = soundTransform; // Magic setter
        return volume;
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    public function isPaused () :Bool
    {
        return _pausePosition >= 0;
    }

    public function setPaused (paused :Bool) :Bool
    {
        if (paused != isPaused()) {
            if (paused) {
                _pausePosition = _channel.position;
                _channel.stop();
            } else {
                // FIXME(bruno): If this a one-shot sound, play a new channel at the old position.
                // But if it's looping, we have to start back at the beginning or Flash will only
                // seek back to _pausePosition on each loop. Maybe handle looping manually in this
                // case?
                var startPosition = (_loops > 0) ? 0 : _pausePosition;
                _channel = _sound.fms.play(startPosition, _loops, _channel.soundTransform);
                _pausePosition = -1;
            }
        }
        return paused;
    }

    public function getPosition () :Float
    {
        return _channel.position;
    }

    private var _sound :FlashSound;
    private var _channel :SoundChannel;
    private var _pausePosition :Float;
    private var _loops :Int;
}
