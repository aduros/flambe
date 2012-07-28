//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.ui.Mouse;

import flambe.input.MouseCursor;

class FlashMouse extends BasicMouse
{
    public function new (pointer :BasicPointer)
    {
        super(pointer);
    }

    override public function isSupported () :Bool
    {
        return Mouse.supportsCursor;
    }

    override public function setCursor (cursor :MouseCursor) :MouseCursor
    {
        Mouse.show();
        switch (cursor) {
            case Default: Mouse.cursor = "arrow";
            case Button: Mouse.cursor = "button";
            case None: Mouse.hide();
        }
        return super.setCursor(cursor);
    }
}
