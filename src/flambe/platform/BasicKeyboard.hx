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
        _id = 0;
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
    public function submitDown (charCode :Int)
    {
        if (!isDown(charCode)) {
            _keyStates.set(charCode, true);
            _sharedEvent._internal_init(++_id, charCode);
            down.emit(_sharedEvent);
        }
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (charCode :Int)
    {
        if (isDown(charCode)) {
            _keyStates.remove(charCode);
            _sharedEvent._internal_init(++_id, charCode);
            up.emit(_sharedEvent);
        }
    }

    private static var _sharedEvent = new KeyEvent();

    private var _id :Int;
    private var _keyStates :IntHash<Bool>;
}
