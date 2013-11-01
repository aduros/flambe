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
    public var duration (get_duration, null) :Float;
    public var nativeSound :flash.media.Sound;

    public function new (nativeSound :flash.media.Sound)
    {
        this.nativeSound = nativeSound;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return new FlashPlayback(this, volume, 0);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return new FlashPlayback(this, volume, FMath.INT_MAX);
    }

    public function get_duration () :Float
    {
        return nativeSound.length/1000;
    }
}

private class FlashPlayback
    implements Playback,
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get_paused, set_paused) :Bool;
    public var ended (get_ended, null) :Bool;
    public var position (get_position, null) :Float;
    public var sound (get_sound, null) :Sound;

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

    public function get_sound () :Sound
    {
        return _sound;
    }

    inline public function get_paused () :Bool
    {
        return _pausePosition >= 0;
    }

    public function set_paused (paused :Bool) :Bool
    {
        if (paused != get_paused()) {
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

    inline public function get_ended () :Bool
    {
        return _ended;
    }

    public function get_position () :Float
    {
        return _channel.position/1000;
    }

    public function update (dt :Float) :Bool
    {
        volume.update(dt);

        if (ended || paused) {
            // Allow ended or paused sounds to be garbage collected
            _tickableAdded = false;
            return true;
        }
        return false;
    }

    public function dispose ()
    {
        paused = true;
        _ended = true;

        //EDIT(Bradley): This must occur to allow garbage collection of sounds.
        _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }

    private function onSoundComplete (_)
    {
        _ended = true;
    }

    private function playAudio (startPosition :Float, soundTransform :SoundTransform)
    {
        _channel = _sound.nativeSound.play(startPosition, _loops, soundTransform);

        //Prevent _channel from ever being null, since null can be returned from flash.media.Sound.play() if 
        //Flash runs out of sound channels. This can (also) happen if many sounds fail to be released from memory.
        if (_channel == null)
        {
            _channel = new SoundChannel();

            //There should be a warning here to notify we have apparently run out of memory for sounds.
            //Sound will not play when this happens.
            #if debug
            trace("Warning: Null sound channel after " + count + " playAudio calls!");
            #end
        }

        //EDIT(Bradley): Use weak listener so sounds can be garbage collected if they never get disposed.
        _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
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
