//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.ui.KeyboardType;

class FlashKeyboard extends BasicKeyboard
{
    public function new (stage :Stage)
    {
        super();
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }

    public static function shouldUse () :Bool
    {
        return flash.ui.Keyboard.physicalKeyboardType != NONE;
    }

    private function onKeyDown (event :KeyboardEvent)
    {
        if (submitDown(event.keyCode)) {
            event.preventDefault();
        }
    }

    private function onKeyUp (event :KeyboardEvent)
    {
        submitUp(event.keyCode);
    }
}
