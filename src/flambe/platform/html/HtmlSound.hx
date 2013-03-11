//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.animation.AnimatedFloat;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;
import flambe.util.Disposable;

class HtmlSound
    implements Sound
{
    public var duration (get, null) :Float;
    public var audioElement :Dynamic; // TODO(bruno): Use typed audio element extern

    public function new (audioElement :Dynamic)
    {
        this.audioElement = audioElement;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return new HtmlPlayback(this, volume, false);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return new HtmlPlayback(this, volume, true);
    }

    public function get_duration () :Float
    {
        return audioElement.duration;
    }
}

private class HtmlPlayback
    implements Playback,
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get, set) :Bool;
    public var ended (get, null) :Bool;
    public var position (get, null) :Float;
    public var sound (get, null) :Sound;

    public function new (sound :HtmlSound, volume :Float, loop :Bool)
    {
        _sound = sound;
        _tickableAdded = false;

        // Create a copy of the original sound's element. Note that cloneNode() doesn't work in IE
        _clonedElement = Lib.document.createElement("audio");
        _clonedElement.loop = loop;
        _clonedElement.src = sound.audioElement.src;

        this.volume = new AnimatedFloat(volume, function (_,_) updateVolume());
        updateVolume();

        playAudio();
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

    inline public function get_ended () :Bool
    {
        return _clonedElement.ended;
    }

    public function get_position () :Float
    {
        return _clonedElement.currentTime;
    }

    public function update (dt :Float) :Bool
    {
        volume.update(dt);

        if (ended || paused) {
            // Allow ended or paused sounds to be garbage collected
            _tickableAdded = false;

            // Release System references
            _volumeBinding.dispose();
            return true;
        }
        return false;
    }

    public function dispose ()
    {
        paused = true;
    }

    private function playAudio ()
    {
        _clonedElement.play();

        if (!_tickableAdded) {
            HtmlPlatform.instance.mainLoop.addTickable(this);
            _tickableAdded = true;

            // Claim System references
            _volumeBinding = System.volume.changed.connect(function(_,_) updateVolume());
        }
    }

    private function updateVolume ()
    {
        _clonedElement.volume = System.volume._ * volume._;
    }

    private var _sound :HtmlSound;
    private var _clonedElement :Dynamic;
    private var _volumeBinding :Disposable;
    private var _tickableAdded :Bool;
}
