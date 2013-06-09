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

class DummyKeyboard
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
    }

    public function get_supported () :Bool
    {
        return false;
    }

    public function isDown (key :Key) :Bool
    {
        return false;
    }
}
