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
import flambe.util.Disposable;
import flambe.util.Value;

class FlashSound extends BasicAsset<FlashSound>
    implements Sound
{
    public var duration (get, null) :Float;
    public var nativeSound :flash.media.Sound;

    public function new (nativeSound :flash.media.Sound)
    {
        super();
        this.nativeSound = nativeSound;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        assertNotDisposed();

#if ios
        // Temporary hack around a bug in Haxe+AIR+iOS:
        // https://github.com/HaxeFoundation/haxe/issues/2431
        if (Math.isNaN(volume)) volume = 1.0;
#end
        return new FlashPlayback(this, volume, 0);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        assertNotDisposed();

#if ios
        // Temporary hack around a bug in Haxe+AIR+iOS:
        // https://github.com/HaxeFoundation/haxe/issues/2431
        if (Math.isNaN(volume)) volume = 1.0;
#end
        return new FlashPlayback(this, volume, FMath.INT_MAX);
    }

    public function get_duration () :Float
    {
        assertNotDisposed();

        return nativeSound.length/1000;
    }

    override private function copyFrom (that :FlashSound)
    {
        this.nativeSound = that.nativeSound;
    }

    override private function onDisposed ()
    {
        nativeSound = null;
    }
}

private class FlashPlayback
    implements Playback
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get, set) :Bool;
    public var complete (get, null) :Value<Bool>;
    public var position (get, null) :Float;
    public var sound (get, null) :Sound;

    public function new (sound :FlashSound, volume :Float, loops :Int)
    {
        _sound = sound;
        _loops = loops;
        this.volume = new AnimatedFloat(volume, onVolumeChanged);
        _complete = new Value<Bool>(false);

        playAudio(0, new SoundTransform(volume));

        // Don't start playing until visible
        if (System.hidden._) {
            paused = true;
        }
    }

    public function onVolumeChanged (volume :Float, _)
    {
        if (_channel != null) {
            var soundTransform = _channel.soundTransform;
            soundTransform.volume = volume;
            _channel.soundTransform = soundTransform; // Magic setter
        }
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
        if (_channel != null && paused != get_paused()) {
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

    inline public function get_complete () :Value<Bool>
    {
        return _complete;
    }

    public function get_position () :Float
    {
        return (_channel != null) ? _channel.position/1000 : 0;
    }

    public function update (dt :Float) :Bool
    {
        volume.update(dt);

        if (_complete._ || paused) {
            // Allow complete or paused sounds to be garbage collected
            _tickableAdded = false;

            // Release references
            _hideBinding.dispose();
            _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);

            return true;
        }
        return false;
    }

    public function dispose ()
    {
        paused = true;
        _complete._ = true;
    }

    private function onSoundComplete (_)
    {
        _complete._ = true;
    }

    private function playAudio (startPosition :Float, soundTransform :SoundTransform)
    {
        _channel = _sound.nativeSound.play(startPosition, _loops, soundTransform);
        if (_channel == null) {
            // Sound.play may return null if the playback couldn't be started for some reason:
            // http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/Sound.html#play()
#if debug
            var url = _sound.nativeSound.url;
            Log.warn("Sound could not be played. No available channels?", ["url", url]);
#end
            dispose();
            return;
        }

        _pausePosition = -1;
        _complete._ = false;

        if (!_tickableAdded) {
            FlashPlatform.instance.mainLoop.addTickable(this);
            _tickableAdded = true;

            // Claim references
            _hideBinding = System.hidden.changed.connect(function(hidden,_) {
                if (hidden) {
                    _wasPaused = get_paused();
                    this.paused = true;
                } else {
                    this.paused = _wasPaused;
                }
            });
            _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }
    }

    private var _sound :FlashSound;
    private var _channel :SoundChannel;
    private var _loops :Int;

    private var _pausePosition :Float;
    private var _wasPaused :Bool;
    private var _complete :Value<Bool>;
    private var _tickableAdded :Bool;
    private var _hideBinding :Disposable;
}
