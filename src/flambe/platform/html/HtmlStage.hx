//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.platform.Stage;
import flambe.util.Signal0;

class HtmlStage
    implements Stage
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var resize (default, null) :Signal0;

    public function new (canvas :Dynamic)
    {
        _canvas = canvas;
        resize = new Signal0();

        (untyped Lib.window).addEventListener("resize", onResize, false);
        onResize();
    }

    public function getWidth () :Int
    {
        return _canvas.width;
    }

    public function getHeight () :Int
    {
        return _canvas.height;
    }

    public function lockOrientation (orient :Orientation)
    {
        // Nothing until mobile browsers support it
    }

    private function onResize ()
    {
        // Resize the canvas to match its container's bounds
        var container = _canvas.parentNode;

        var rect = container.getBoundingClientRect();
        _canvas.width = rect.width;
        _canvas.height = rect.height;

        resize.emit();
    }

    private var _canvas :Dynamic;
}
