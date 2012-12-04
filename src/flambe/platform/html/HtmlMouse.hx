//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.input.MouseCursor;

class HtmlMouse extends BasicMouse
{
    public function new (pointer :BasicPointer, canvas :Dynamic)
    {
        super(pointer);
        _canvas = canvas;
    }

    override public function set_cursor (cursor :MouseCursor) :MouseCursor
    {
        var name;
        switch (cursor) {
            case Default: name = ""; // inherit
            case Button: name = "pointer";
            case None: name = "none";
        }
        _canvas.style.cursor = name;

        return super.set_cursor(cursor);
    }

    private var _canvas :Dynamic;
}
