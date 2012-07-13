//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.animation.AnimatedFloat;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;

class WebAudioSound
    implements Sound
{
    public static var supported (isSupported, null) :Bool;

    /**
     * The shared AudioContext.
     */
    public static var ctx :Dynamic;

    public var duration (getDuration, null) :Float;

    public var buffer :Dynamic;

    public function new (buffer :Dynamic)
    {
        this.buffer = buffer;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return new WebAudioPlayback(this, volume, false);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return new WebAudioPlayback(this, volume, true);
    }

    public function getDuration () :Float
    {
        return buffer.duration;
    }

    private static function isSupported () :Bool
    {
        if (_detectSupport) {
            _detectSupport = false;

            var AudioContext = HtmlUtil.loadExtension("AudioContext").value;
            ctx = (AudioContext != null) ?  untyped __new__(AudioContext) : null;
        }

        return ctx != null;
    }

    private static var _detectSupport = true;
}

private class WebAudioPlayback
    implements Playback,
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (isPaused, setPaused) :Bool;
    public var ended (isEnded, null) :Bool;
    public var position (getPosition, null) :Float;
    public var sound (getSound, null) :Sound;

    public function new (sound :WebAudioSound, volume :Float, loop :Bool)
    {
        _sound = sound;
        _head = WebAudioSound.ctx.destination;

        _sourceNode = WebAudioSound.ctx.createBufferSource();
        _sourceNode.buffer = sound.buffer;
        _sourceNode.loop = loop;
        _sourceNode.noteOn(0);
        playAudio();

        this.volume = new AnimatedFloat(volume, function (v, _) {
            setVolume(v);
        });
        if (volume != 1) {
            setVolume(volume);
        }
    }

    public function getSound () :Sound
    {
        return _sound;
    }

    inline public function isPaused () :Bool
    {
        return _pausedAt >= 0;
    }

    public function setPaused (paused :Bool) :Bool
    {
        if (paused != isPaused()) {
            if (paused) {
                _sourceNode.disconnect();
                _pausedAt = getPosition();
            } else {
                playAudio();
            }
        }
        return paused;
    }

    inline public function isEnded () :Bool
    {
        return _sourceNode.playbackState == 3; // == FINISHED_STATE
    }

    public function getPosition () :Float
    {
        // Web Audio sure doesn't make this simple...
        if (isEnded()) {
            return _sound.duration;

        } else if (isPaused()) {
            return _pausedAt;

        } else {
            var elapsed = WebAudioSound.ctx.currentTime - _startedAt;
            return elapsed % _sound.duration;
        }
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
    }

    private function setVolume (volume :Float)
    {
        if (_gainNode == null) {
            _gainNode = WebAudioSound.ctx.createGainNode();
            insertNode(_gainNode);
        }
        _gainNode.gain.value = volume;
    }

    private function insertNode (head :Dynamic)
    {
        if (!isPaused()) {
            _sourceNode.disconnect();
            _sourceNode.connect(head);
        }
        head.connect(_head);
        _head = head;
    }

    private function playAudio ()
    {
        _sourceNode.connect(_head);
        _startedAt = WebAudioSound.ctx.currentTime;
        _pausedAt = -1;

        if (!_tickableAdded) {
            _tickableAdded = true;
            HtmlPlatform.instance.mainLoop.addTickable(this);
        }
    }

    private var _sound :WebAudioSound;

    private var _pausedAt :Float;
    private var _startedAt :Float;

    private var _sourceNode :Dynamic;
    private var _gainNode :Dynamic;

    // The first node of the output chain, not including the source node
    private var _head :Dynamic;

    private var _tickableAdded :Bool;
}
