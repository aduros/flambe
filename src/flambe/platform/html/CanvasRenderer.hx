//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import flambe.display.Graphics;
import flambe.display.Texture;

class CanvasRenderer
    implements Renderer
{
    public function new (canvas :CanvasElement)
    {
        _graphics = new CanvasGraphics(canvas);
        System.hasGPU._ = true;
    }

    public function createTexture (image :Dynamic) :Texture
    {
        return new CanvasTexture(CANVAS_TEXTURES ? HtmlUtil.createCanvas(image) : image);
    }

    public function createEmptyTexture (width :Int, height :Int) :Texture
    {
        return new CanvasTexture(HtmlUtil.createEmptyCanvas(width, height));
    }

    public function willRender () :Graphics
    {
        _graphics.willRender();
        return _graphics;
    }

    public function didRender ()
    {
    }

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool = (function () {
        // On iOS, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/8
        var pattern = ~/(iPhone|iPod|iPad)/;
        return pattern.match(Browser.window.navigator.userAgent);
    })();

    private var _graphics :CanvasGraphics;
}
