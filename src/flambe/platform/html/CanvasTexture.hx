//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class CanvasTexture
    implements Texture
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;
    public var ctx (getContext, null) :DrawingContext;

    // The Image (or sometimes Canvas) used for most draw calls
    public var image :Dynamic;

    // The CanvasPattern required for drawPattern, lazily instantiated
    public var pattern :Dynamic;

    public function new ()
    {
    }

    inline private function getWidth () :Int
    {
        return image.width;
    }

    inline private function getHeight () :Int
    {
        return image.height;
    }

    private function getContext () :CanvasDrawingContext
    {
        if (_ctx == null) {
            // FIXME(bruno): Ensure image is a canvas element
            _ctx = new CanvasDrawingContext(image);
        }
        return _ctx;
    }

    private var _ctx :CanvasDrawingContext = null;
}
