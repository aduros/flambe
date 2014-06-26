//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.animation.AnimatedFloat;
import flambe.sound.Playback;
import flambe.sound.Sound;
import flambe.util.Value;

/**
 * An empty sound used in environments that don't support audio.
 */
class DummySound extends BasicAsset<DummySound>
    implements Sound
{
    public var duration (get, null) :Float;

    public function new ()
    {
        super();
        _playback = new DummyPlayback(this);
    }

    public function play (volume :Float = 1.0) :Playback
    {
        return _playback;
    }

    public function loop (volume :Float = 1.0) :Playback
    {
        return _playback;
    }

    public function get_duration () :Float
    {
        return 0;
    }

    override private function copyFrom (asset :DummySound)
    {
        // Nothing at all
    }

    override private function onDisposed ()
    {
        // Nothing at all
    }

    public static function getInstance () :DummySound
    {
        if (_instance == null) {
            _instance = new DummySound();
        }
        return _instance;
    }

    private static var _instance :DummySound;

    private var _playback :DummyPlayback;
}

// This should be immutable too
class DummyPlayback
    implements Playback
{
    public var volume (default, null) :AnimatedFloat;
    public var paused (get, set) :Bool;
    public var complete (get, null) :Value<Bool>;
    public var position (get, null) :Float;
    public var sound (get, null) :Sound;

    public function new (sound :Sound)
    {
        _sound = sound;
        this.volume = new AnimatedFloat(0); // A little quirky? All DummyPlaybacks share the same volume
        _complete = new Value<Bool>(true);
    }

    public function get_sound () :Sound
    {
        return _sound;
    }

    public function get_paused () :Bool
    {
        return true;
    }

    public function set_paused (paused :Bool) :Bool
    {
        return true;
    }

    public function get_complete () :Value<Bool>
    {
        return _complete;
    }

    public function get_position () :Float
    {
        return 0;
    }

    public function dispose ()
    {
        // Nothing
    }

    private var _sound :Sound;

    private var _complete :Value<Bool>;
}
