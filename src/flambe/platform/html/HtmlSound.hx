//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.animation.Property;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;

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

private class HtmlPlayback
    implements Playback,
    implements Tickable
{
    public var volume (default, null) :PFloat;
    public var paused (isPaused, setPaused) :Bool;
    public var ended (isEnded, null) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :HtmlSound, volume :Float, loop :Bool)
    {
        _sound = sound;
        _tickableAdded = false;
        this.volume = new PFloat(volume, function (v) {
            _clone.volume = v._;
        });

        // Create a copy of the original sound's element. Note that cloneNode() doesn't work in IE
        _clone = Lib.document.createElement("audio");
        _clone.volume = volume;
        _clone.loop = loop;
        _clone.src = sound.element.src;

        playAudio();
    }

    public function setVolume (volume :Float) :Float
    {
        return _clone.volume = volume;
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    inline public function isPaused () :Bool
    {
        return _clone.paused;
    }

    public function setPaused (paused :Bool) :Bool
    {
        if (_clone.paused != paused) {
            if (paused) {
                _clone.pause();
            } else {
                playAudio();
            }
        }
        return paused;
    }

    inline public function isEnded () :Bool
    {
        return _clone.ended;
    }

    public function getPosition () :Float
    {
        return _clone.currentTime*1000;
    }

    public function update (dt :Int) :Bool
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
    }

    private function playAudio ()
    {
        _clone.play();

        if (!_tickableAdded) {
            HtmlAppDriver.getInstance().mainLoop.addTickable(this);
            _tickableAdded = true;
        }
    }

    private var _sound :HtmlSound;
    private var _clone :Dynamic;

    private var _tickableAdded :Bool;
}
