//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.sound.Sound;
import flambe.sound.Playback;

class HtmlSound
    implements Sound
{
    public var duration (getDuration, null) :Float;
    public var element :Dynamic; // TODO(bruno): Use typed audio element extern

    public function new (element :Dynamic)
    {
        this.element = element;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return new HtmlPlayback(this, volume, false);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return new HtmlPlayback(this, volume, true);
    }

    public function getDuration () :Float
    {
        return element.duration*1000;
    }
}

class HtmlPlayback
    implements Playback
{
    public var volume (getVolume, setVolume) :Float;
    public var paused (isPaused, setPaused) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :HtmlSound, volume :Float, loop :Bool)
    {
        _sound = sound;

        // Create a copy of the original sound's element. Note that cloneNode() doesn't work in IE
        _clone = Lib.document.createElement("audio");
        _clone.volume = volume;
        _clone.loop = loop;
        _clone.src = sound.element.src;
        _clone.play();
    }

    public function getVolume () :Float
    {
        return _clone.volume;
    }

    public function setVolume (volume :Float) :Float
    {
        return _clone.volume = volume;
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    public function isPaused () :Bool
    {
        return _clone.paused;
    }

    public function setPaused (paused :Bool) :Bool
    {
        if (_clone.paused != paused) {
            if (paused) {
                _clone.pause();
            } else {
                _clone.play();
            }
        }
        return paused;
    }

    public function getPosition () :Float
    {
        return _clone.currentTime*1000;
    }

    private var _sound :HtmlSound;
    private var _clone :Dynamic;
}
