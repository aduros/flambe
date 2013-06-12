//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Stage;
import flash.events.TouchEvent;
import flash.ui.Multitouch;

class AirTouch extends BasicTouch
{
    public function new (pointer :BasicPointer, stage :Stage)
    {
        super(pointer, Multitouch.maxTouchPoints);

        // Enable touch events, and disable emulated mouse events. Note that since mapToTouchMouse
        // requires AIR, touch is intentionally not enabled when running in the browser. One more
        // reason to switch to the HTML target for the browser!
        Multitouch.inputMode = TOUCH_POINT;
        Multitouch.mapTouchToMouse = false;

        stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
        stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
        stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
    }

    public static function shouldUse () :Bool
    {
        return Multitouch.supportsTouchEvents;
    }

    private function onTouchBegin (event :TouchEvent)
    {
        submitDown(event.touchPointID, event.stageX, event.stageY);
    }

    private function onTouchMove (event :TouchEvent)
    {
        submitMove(event.touchPointID, event.stageX, event.stageY);
    }

    private function onTouchEnd (event :TouchEvent)
    {
        submitUp(event.touchPointID, event.stageX, event.stageY);
    }
}
