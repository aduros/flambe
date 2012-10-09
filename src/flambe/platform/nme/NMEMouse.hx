//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.display.Stage;
import nme.events.MouseEvent;
import nme.ui.Mouse;

import flambe.input.MouseCursor;

class NMEMouse extends BasicMouse
{
    public function new (pointer :BasicPointer, stage :Stage)
    {
        super(pointer);

        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

#if flash11_2
        stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
        stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
#end
    }

    public static function shouldUse () :Bool
    {
    	return true;
        //return Mouse.supportsCursor;
    }

    override public function setCursor (cursor :MouseCursor) :MouseCursor
    {
        /*Mouse.show();
        switch (cursor) {
            case Default: Mouse.cursor = "arrow";
            case Button: Mouse.cursor = "button";
            case None: Mouse.hide();
        }
        return super.setCursor(cursor);*/
        return super.setCursor(cursor);
    }

    private function onMouseDown (event :MouseEvent)
    {
        var buttonCode;
        switch (event.type) {
            case "middleMouseDown": buttonCode = MouseCodes.MIDDLE;
            case "rightMouseDown": buttonCode = MouseCodes.RIGHT;
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
            case "middleMouseUp": buttonCode = MouseCodes.MIDDLE;
            case "rightMouseUp": buttonCode = MouseCodes.RIGHT;
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
