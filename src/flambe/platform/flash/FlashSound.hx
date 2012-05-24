//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.events.Event;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import flambe.animation.AnimatedFloat;
import flambe.math.FMath;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;

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

private class FlashPlayback
    implements Playback,
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (isPaused, setPaused) :Bool;
    public var ended (isEnded, null) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :FlashSound, volume :Float, loops :Int)
    {
        _sound = sound;
        _loops = loops;
        this.volume = new AnimatedFloat(volume, onVolumeChanged);

        playAudio(0, new SoundTransform(volume));
    }

    public function onVolumeChanged (volume :Float, _)
    {
        var soundTransform = _channel.soundTransform;
        soundTransform.volume = volume;
        _channel.soundTransform = soundTransform; // Magic setter
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    inline public function isPaused () :Bool
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
                playAudio(startPosition, _channel.soundTransform);
            }
        }
        return paused;
    }

    inline public function isEnded () :Bool
    {
        return _ended;
    }

    public function getPosition () :Float
    {
        return _channel.position;
    }

    public function update (dt :Float) :Bool
    {
        volume.update(dt);

        if (isEnded() || isPaused()) {
            // Allow ended or paused sounds to be garbage collected
            _tickableAdded = false;
            return true;
        }
        return false;
    }

    public function dispose ()
    {
        setPaused(true);
        _ended = true;
    }

    private function onSoundComplete (_)
    {
        _ended = true;
    }

    private function playAudio (startPosition :Float, soundTransform :SoundTransform)
    {
        _channel = _sound.fms.play(startPosition, _loops, soundTransform);
        _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        _pausePosition = -1;
        _ended = false;

        if (!_tickableAdded) {
            FlashPlatform.instance.mainLoop.addTickable(this);
            _tickableAdded = true;
        }
    }

    private var _sound :FlashSound;
    private var _channel :SoundChannel;
    private var _loops :Int;

    private var _pausePosition :Float;
    private var _ended :Bool;
    private var _tickableAdded :Bool;
}
