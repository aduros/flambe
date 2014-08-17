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

    public function play (volume :Float = 1.0, ?offset:Float=0, ?duration:Float=0) :Playback
    {
        assertNotDisposed();

#if ios
        // Temporary hack around a bug in Haxe+AIR+iOS:
        // https://github.com/HaxeFoundation/haxe/issues/2431
        if (Math.isNaN(volume)) volume = 1.0;
        if (Math.isNaN(offset)) offset = .0;
        if (Math.isNaN(duration)) duration = .0;
#end
        return new FlashPlayback(this, volume, false, offset, duration);
    }

    public function loop (volume :Float = 1.0, ?offset:Float=0, ?duration:Float=0) :Playback
    {
        assertNotDisposed();

#if ios
        // Temporary hack around a bug in Haxe+AIR+iOS:
        // https://github.com/HaxeFoundation/haxe/issues/2431
        if (Math.isNaN(volume)) volume = 1.0;
        if (Math.isNaN(offset)) offset = .0;
        if (Math.isNaN(duration)) duration = .0;
#end
        return new FlashPlayback(this, volume, true, offset, duration);
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

	
    public function new (sound :FlashSound, volume :Float, loop:Bool=false, offset:Float=0, duration:Float=0)
    {
        _sound = sound;
        _loop = loop;
		
		_playOffset = offset * 1000;
		
		if (duration == 0) _playDuration = (_sound.duration * 1000) - _playOffset;
		else _playDuration = duration * 1000;
		
        this.volume = new AnimatedFloat(volume, onVolumeChanged);
        _complete = new Value<Bool>(false);

        playAudio(_playOffset, new SoundTransform(volume));
		
        // Don't start playing until visible
        if (System.hidden._) paused = true;
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
				playAudio(_pausePosition, _channel.soundTransform);
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
        } else {
			
			var now = _channel==null ? 0 : _channel.position; // millis
			var end = _playOffset + _playDuration;
			
			 if (_loop) { // handle looping - return to _playOffset postion
				if (now >= end) {
					_channel.stop();
					playAudio(_playOffset, _channel.soundTransform);					
				}
				
			} else if(!_loop && _playDuration > 0) {
				// no loop, but have duration option - and are at or past the end time?
				if (now >= end) {
					_complete._ = true;
					dispose();	
				}
			}
		}
		
        return false;
    }

    public function dispose ()
    {
        _pausePosition = -1;
        _complete = null;
		
		FlashPlatform.instance.mainLoop.removeTickable(this);
		_tickableAdded = false;
        
		// Release references
		if (_hideBinding != null) {
			_hideBinding.dispose();
			_hideBinding = null;
		}
		
		if (_channel != null) {
			_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_channel.stop();
			_channel = null;
		}
    }

    private function onSoundComplete (_)
    {
        if (_loop) {
			playAudio(_playOffset, _channel.soundTransform);
		} else {
			_complete._ = true;
			dispose();
		}
    }

    private function playAudio (startPosition :Float, soundTransform :SoundTransform)
    {
        _channel = _sound.nativeSound.play(startPosition, 0, soundTransform);
		
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
    private var _loop :Bool;
    var _playOffset :Float; //ms
    var _playDuration :Float; //ms

    private var _pausePosition :Float;
    private var _wasPaused :Bool;
    private var _complete :Value<Bool>;
    private var _tickableAdded :Bool;
    private var _hideBinding :Disposable;
}
