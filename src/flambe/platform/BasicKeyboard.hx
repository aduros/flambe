//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Keyboard;
import flambe.input.KeyEvent;
import flambe.util.Signal1;

class BasicKeyboard
    implements Keyboard
{
    public var supported (isSupported, null) :Bool;

    public var down (default, null) :Signal1<KeyEvent>;
    public var up (default, null) :Signal1<KeyEvent>;

    public function new ()
    {
        down = new Signal1();
        up = new Signal1();
        _keyStates = new IntHash();
    }

    public function isSupported () :Bool
    {
        return true;
    }

    inline public function isDown (charCode :Int) :Bool
    {
        return _keyStates.exists(charCode);
    }

    /**
     * Called by the platform to handle a down event.
     */
    public function submitDown (event :KeyEvent)
    {
        if (!isDown(event.charCode)) {
            _keyStates.set(event.charCode, true);
            down.emit(event);
        }
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (event :KeyEvent)
    {
        if (isDown(event.charCode)) {
            _keyStates.remove(event.charCode);
            up.emit(event);
        }
    }

    private var _keyStates :IntHash<Bool>;
}
