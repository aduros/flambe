//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.animation.AnimatedFloat;
import flambe.platform.Tickable;
import flambe.sound.Playback;
import flambe.sound.Sound;
import flambe.util.Disposable;
import flambe.util.Value;

class WebAudioSound extends BasicAsset<WebAudioSound>
    implements Sound
{
    public static var supported (get, null) :Bool;

    /**
     * The shared AudioContext.
     */
    public static var ctx :Dynamic = null;

    /**
     * The shared gain node for global system volume.
     */
    public static var gain :Dynamic;

    public var duration (get, null) :Float;

    public var buffer :Dynamic;

    public function new (buffer :Dynamic)
    {
        super();
        this.buffer = buffer;
    }

    public function play (volume :Float = 1.0) :Playback
    {
        assertNotDisposed();

        return new WebAudioPlayback(this, volume, false);
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        assertNotDisposed();

        return new WebAudioPlayback(this, volume, true);
    }

    public function get_duration () :Float
    {
        assertNotDisposed();

        return buffer.duration;
    }

    override private function copyFrom (that :WebAudioSound)
    {
        this.buffer = that.buffer;
    }

    override private function onDisposed ()
    {
        buffer = null;
    }

    private static function get_supported () :Bool
    {
        if (_detectSupport) {
            _detectSupport = false;

            var AudioContext = HtmlUtil.loadExtension("AudioContext").value;
            if (AudioContext != null) {
                ctx = untyped __new__(AudioContext);
                gain = createGain();
                gain.connect(ctx.destination);

                System.volume.watch(function(volume, _) {
                    gain.gain.value = volume;
                });
            }
        }

        return ctx != null;
    }

    public static function createGain () :Dynamic
    {
        // Fall back to createGainNode used in iOS Safari
        // https://developer.mozilla.org/en-US/docs/Web_Audio_API/Porting_webkitAudioContext_code_to_standards_based_AudioContext
        return (ctx.createGain != null) ? ctx.createGain() : ctx.createGainNode();
    }

    public static function start (node :Dynamic, time :Float)
    {
        // Fall back to noteOn used in iOS Safari
        if (node.start != null) {
            node.start(time);
        } else {
            node.noteOn(time);
        }
    }

    private static var _detectSupport = true;
}

private class WebAudioPlayback
    implements Playback
    implements Tickable
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get, set) :Bool;
    public var complete (get, null) :Value<Bool>;
    public var position (get, null) :Float;
    public var sound (get, null) :Sound;

    public function new (sound :WebAudioSound, volume :Float, loop :Bool)
    {
        _sound = sound;
        _head = WebAudioSound.gain;
        _complete = new Value<Bool>(false);

        _sourceNode = WebAudioSound.ctx.createBufferSource();
        _sourceNode.buffer = sound.buffer;
        _sourceNode.loop = loop;
        _sourceNode.onended = function () _complete._ = true; // Not supported on iOS!
        WebAudioSound.start(_sourceNode, 0);
        playAudio();

        this.volume = new AnimatedFloat(volume, function (v, _) {
            setVolume(v);
        });
        if (volume != 1) {
            setVolume(volume);
        }

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
        return _pausedAt >= 0;
    }

    public function set_paused (paused :Bool) :Bool
    {
        if (paused != get_paused()) {
            if (paused) {
                _sourceNode.disconnect();
                _pausedAt = position;
            } else {
                playAudio();
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
        // Web Audio sure doesn't make this simple...
        if (_complete._) {
            return _sound.duration;

        } else if (paused) {
            return _pausedAt;

        } else {
            var elapsed = WebAudioSound.ctx.currentTime - _startedAt;
            return elapsed % _sound.duration;
        }
    }

    public function update (dt :Float) :Bool
    {
        volume.update(dt);

        // playbackState is used in old browsers that don't support onended (iOS)
        if (_sourceNode.playbackState == 3 /* FINISHED_STATE */) {
            _complete._ = true;
        }

        if (_complete._ || paused) {
            // Allow complete or paused sounds to be garbage collected
            _tickableAdded = false;

            // Release System references
            _hideBinding.dispose();

            return true;
        }
        return false;
    }

    public function dispose ()
    {
        paused = true;
        _complete._ = true;
    }

    private function setVolume (volume :Float)
    {
        if (_gainNode == null) {
            _gainNode = WebAudioSound.createGain();
            insertNode(_gainNode);
        }
        _gainNode.gain.value = volume;
    }

    private function insertNode (head :Dynamic)
    {
        if (!paused) {
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
            HtmlPlatform.instance.mainLoop.addTickable(this);
            _tickableAdded = true;

            // Claim System references
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

    private var _sound :WebAudioSound;

    private var _pausedAt :Float;
    private var _startedAt :Float;
    private var _wasPaused :Bool;

    private var _sourceNode :Dynamic;
    private var _gainNode :Dynamic;

    // The first node of the output chain, not including the source node
    private var _head :Dynamic;

    private var _hideBinding :Disposable;
    private var _tickableAdded :Bool;

    private var _complete :Value<Bool>;
}
