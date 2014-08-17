//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;

import flambe.math.FMath;
import flambe.animation.AnimatedFloat;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;
import flambe.util.Disposable;
import flambe.util.Value;

class HtmlSound extends BasicAsset<HtmlSound>
    implements Sound
{
    public var duration (get, null) :Float;
    public var audioElement :Dynamic; // TODO(bruno): Use typed audio element extern
	
    public function new (audioElement :Dynamic)
    {
        super();
        this.audioElement = audioElement;
    }

    public function play (volume :Float = 1.0, offset:Float=0, duration:Float=0) :Playback
    {
        assertNotDisposed();

        return new HtmlPlayback(this, volume, false, offset, duration);
    }

    public function loop (volume :Float = 1.0, offset:Float=0, duration:Float=0) :Playback
    {
        assertNotDisposed();

        return new HtmlPlayback(this, volume, true, offset, duration);
    }

    public function get_duration () :Float
    {
        assertNotDisposed();

        return audioElement.duration;
    }

    override private function copyFrom (that :HtmlSound)
    {
        this.audioElement = that.audioElement;
    }

    override private function onDisposed ()
    {
        audioElement = null;
    }
}

private class HtmlPlayback
    implements Playback
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get, set) :Bool;
    public var complete (get, null) :Value<Bool>;
    public var position (get, null) :Float;
    public var sound (get, null) :Sound;
	
    public function new (sound :HtmlSound, volume :Float, loop :Bool, offset:Float=0, duration:Float=0)
    {
        _sound = sound;
		_loop = loop;		
		
		_playOffset 	= FMath.clamp(offset, .0, sound.duration);
		_playDuration 	= FMath.max(.0, FMath.min(duration, sound.duration));
		
		if(_playDuration==.0 && !_loop) _playDuration = sound.duration - _playOffset;	
		
		_waitingToSeek = _playOffset > 0;
        _tickableAdded = false;

        // Create a copy of the original sound's element. Note that cloneNode() doesn't work in IE
        _clonedElement = Browser.document.createAudioElement();
        _clonedElement.loop = _loop && (offset==0&&duration==0); // only use the .loop property for looping if offset + duration were not set.
        _clonedElement.src = sound.audioElement.src;
		
        this.volume = new AnimatedFloat(volume, function (_,_) updateVolume());
        updateVolume();
        _complete = new Value<Bool>(false);
		
        playAudio();

        // Don't start playing until visible
        if (System.hidden._) {
            paused = true;
        }
    }

    public function get_sound () :Sound
    {
        return _sound;
    }

    inline public function get_paused () :Bool
    {
        return _clonedElement.paused;
    }

    public function set_paused (paused :Bool) :Bool
    {
        if (_clonedElement.paused != paused) {
            if (paused) {
                _clonedElement.pause();
            } else {
                playAudio();
            }
        }
        return paused;
    }

    public function get_complete () :Value<Bool>
    {
        return _complete;
    }

    public function get_position () :Float
    {
        return _clonedElement.currentTime;
    }
	
    public function update (dt :Float) :Bool
    {
        volume.update(dt);
        _complete._ = _clonedElement.ended;
		
		
		if (_waitingToSeek) {
			if (canSeekToOffset()) {
				_waitingToSeek = false;
				_clonedElement.currentTime = _playOffset;
				paused = false;
			} else {
				return false;
			}
		}

        if (_complete._ || paused) {
            // Allow complete or paused sounds to be garbage collected
            _tickableAdded = false;

            // Release System references
            _volumeBinding.dispose();
            _hideBinding.dispose();
			
            return true;
			
        } else {
			
			var now = _clonedElement.currentTime;
			var end = _playOffset + _playDuration;
			
			 if (_loop && !_clonedElement.loop) {
				// want to loop, but a custom start/end range is specified
				if (now >= end) _clonedElement.currentTime = _playOffset;
				
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
        HtmlPlatform.instance.mainLoop.removeTickable(this);
        _tickableAdded = false;
		paused = true;
		_waitingToSeek = false;
        _complete = null;
		_clonedElement = null;
		_sound = null;
		// Release System references
		if (_volumeBinding != null) {
			_volumeBinding.dispose();
			_volumeBinding = null;
		}
		if (_hideBinding != null) {
			_hideBinding.dispose();
			_hideBinding = null;
		}
    }
	
    private function playAudio ()
    {
        #if flambe_html_audio_fix
        // Only allow looping audio to play
        // Assumes background music loops
        if (!_clonedElement.loop) {
            return;
        }

        // Only allow one background music
        if (HtmlPlatform.instance.musicPlaying) {
            return;
        }
        HtmlPlatform.instance.musicPlaying = true;
        #end

        _clonedElement.play();
		
		if (_playOffset > 0) {
			if (canSeekToOffset()) {
				_waitingToSeek = false;
				_clonedElement.currentTime = _playOffset;
			} else {
				_waitingToSeek = true;
				if(!get_paused()) paused = true;
			}
		}		
		
        if (!_tickableAdded) {
            HtmlPlatform.instance.mainLoop.addTickable(this);
            _tickableAdded = true;

            // Claim System references
            _volumeBinding = System.volume.changed.connect(function(_,_) updateVolume());
            _hideBinding = System.hidden.changed.connect(function(hidden,_) {
                if (hidden) {
                    _wasPaused = get_paused();
                    this.paused = true;
                } else {
                    this.paused = _wasPaused;
                }
            });
        }
    }
	
	function canSeekToOffset():Bool {	
			
		//  Will throw a DOM Exception: INVALID_STATE_ERR if you try to set currentTime before it's 'ready'... so wait a bit. probably just a tick or two
		// trace("canSeek ? " + _clonedElement.readyState);
		
		if (_clonedElement.readyState >= 1/*MediaElement.HAVE_METADATA*/) {
			var n = _clonedElement.seekable.length;
			var seekable = _clonedElement.seekable;
			for (i in 0...n) {
				var start 	= seekable.start(i);
				var end 	= seekable.end(i);
				if (start <= _playOffset && _playOffset < end) {
					return true;
				}
			}
		}
		return false;
	}
	

    private function updateVolume ()
    {
        _clonedElement.volume = System.volume._ * volume._;
    }

    private var _sound :HtmlSound;
    private var _clonedElement :Dynamic;
    private var _volumeBinding :Disposable;
    private var _tickableAdded :Bool;
    private var _hideBinding :Disposable;
    private var _wasPaused :Bool;

    private var _complete :Value<Bool>;
	
	var _loop:Bool = false;
	var _playOffset:Float = 0;
	var _playDuration:Float = 0;
	var _waitingToSeek = false;
	
}