//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Stage;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import flambe.input.MouseCursor;

class FlashMouse extends BasicMouse
{
    public function new (pointer :BasicPointer, stage :Stage)
    {
        super(pointer);

        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);

        stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);

        stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }

    public static function shouldUse () :Bool
    {
        return Mouse.supportsCursor;
    }

    override public function set_cursor (cursor :MouseCursor) :MouseCursor
    {
        Mouse.show();
        switch (cursor) {
            case Default: Mouse.cursor = "arrow";
            case Button: Mouse.cursor = "button";
            case None: Mouse.hide();
        }
        return super.set_cursor(cursor);
    }

    private function onMouseDown (event :MouseEvent)
    {
        var buttonCode;
        switch (event.type) {
            case MouseEvent.MIDDLE_MOUSE_DOWN: buttonCode = MouseCodes.MIDDLE;
            case MouseEvent.RIGHT_MOUSE_DOWN: buttonCode = MouseCodes.RIGHT;
            default: buttonCode = MouseCodes.LEFT;
        }
        submitDown(event.stageX, event.stageY, buttonCode);
    }

    private function onMouseMove (event :MouseEvent)
    {
        submitMove(event.stageX, event.stageY);
    }

    private function onMouseUp (event :MouseEvent)
    {
        var buttonCode;
        switch (event.type) {
            case MouseEvent.MIDDLE_MOUSE_UP: buttonCode = MouseCodes.MIDDLE;
            case MouseEvent.RIGHT_MOUSE_UP: buttonCode = MouseCodes.RIGHT;
            default: buttonCode = MouseCodes.LEFT;
        }
        submitUp(event.stageX, event.stageY, buttonCode);
    }

    private function onMouseWheel (event :MouseEvent)
    {
        // Flash only fires mouse wheel events on Windows, see issue #32
        submitScroll(event.stageX, event.stageY, event.delta);
    }
}
