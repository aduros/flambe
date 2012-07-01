//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Key;
import flambe.input.Keyboard;
import flambe.input.KeyboardEvent;
import flambe.util.Signal1;

using flambe.platform.KeyCodes;

class BasicKeyboard
    implements Keyboard
{
    public var supported (isSupported, null) :Bool;

    public var down (default, null) :Signal1<KeyboardEvent>;
    public var up (default, null) :Signal1<KeyboardEvent>;

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

    public function isDown (key :Key) :Bool
    {
        return isCodeDown(key.toKeyCode());
    }

    inline private function isCodeDown (keyCode :Int) :Bool
    {
        return _keyStates.exists(keyCode);
    }

    /**
     * Called by the platform to handle a down event.
     */
    public function submitDown (keyCode :Int)
    {
        if (!isCodeDown(keyCode)) {
            _keyStates.set(keyCode, true);
            _sharedEvent._internal_init(++_id, keyCode.toKey());
            down.emit(_sharedEvent);
        }
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (keyCode :Int)
    {
        if (isCodeDown(keyCode)) {
            _keyStates.remove(keyCode);
            _sharedEvent._internal_init(++_id, keyCode.toKey());
            up.emit(_sharedEvent);
        }
    }

    private static var _sharedEvent = new KeyboardEvent();

    private var _id :Int;
    private var _keyStates :IntHash<Bool>;
}
