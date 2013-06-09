//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.KeyboardSystem;
import flambe.util.Signal0;
import flambe.util.Signal1;

using flambe.platform.KeyCodes;

class BasicKeyboard
    implements KeyboardSystem
{
    public var supported (get, null) :Bool;

    public var down (default, null) :Signal1<KeyboardEvent>;
    public var up (default, null) :Signal1<KeyboardEvent>;
    public var backButton (default, null) :Signal0;

    public function new ()
    {
        down = new Signal1();
        up = new Signal1();
        backButton = new Signal0();
        _keyStates = new Map();
    }

    public function get_supported () :Bool
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
     * @return Whether default action should be prevented.
     */
    public function submitDown (keyCode :Int) :Bool
    {
        if (keyCode == KeyCodes.BACK) {
            if (backButton.hasListeners()) {
                backButton.emit();
                return true;
            }
            return false; // No preventDefault
        }

        if (!isCodeDown(keyCode)) {
            _keyStates.set(keyCode, true);
            _sharedEvent.init(_sharedEvent.id+1, keyCode.toKey());
            down.emit(_sharedEvent);
        }
        return true;
    }

    /**
     * Called by the platform to handle an up event.
     */
    public function submitUp (keyCode :Int)
    {
        if (isCodeDown(keyCode)) {
            _keyStates.remove(keyCode);
            _sharedEvent.init(_sharedEvent.id+1, keyCode.toKey());
            up.emit(_sharedEvent);
        }
    }

    private static var _sharedEvent = new KeyboardEvent();

    private var _keyStates :Map<Int,Bool>;
}
