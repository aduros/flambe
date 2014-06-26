//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

class CanvasRenderer
    implements InternalRenderer<Dynamic>
{
    public var type (get, null) :RendererType;
    public var maxTextureSize (get, null) :Int;
    public var hasGPU (get, null) :Value<Bool>;

    public var graphics :InternalGraphics;

    public function new (canvas :CanvasElement)
    {
        graphics = new CanvasGraphics(canvas, #if flambe_transparent true #else false #end);
        _hasGPU = new Value<Bool>(true);
    }

    inline private function get_type () :RendererType
    {
        return Canvas;
    }

    private function get_maxTextureSize () :Int
    {
        // Canvases larger than 1024 prevent hardware acceleration in iOS
        // TODO(bruno): Return 2048 on non-iOS browsers?
        return 1024;
    }

    inline private function get_hasGPU () :Value<Bool>
    {
        return _hasGPU;
    }

    public function createTextureFromImage (image :Dynamic) :CanvasTexture
    {
        var root = new CanvasTextureRoot(CANVAS_TEXTURES ? HtmlUtil.createCanvas(image) : image);
        return root.createTexture(root.width, root.height);
    }

    public function createTexture (width :Int, height :Int) :CanvasTexture
    {
        var root = new CanvasTextureRoot(HtmlUtil.createEmptyCanvas(width, height));
        return root.createTexture(width, height);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :CanvasTexture
    {
        Assert.fail(); // Unsupported
        return null;
    }

    public function willRender ()
    {
        graphics.willRender();
    }

    public function didRender ()
    {
        graphics.didRender();
    }

    public function getName () :String
    {
        return "Canvas";
    }

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool = (function () {
        // On iOS, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/8
        var pattern = ~/(iPhone|iPod|iPad)/;
        return pattern.match(Browser.window.navigator.userAgent);
    })();

    private var _hasGPU :Value<Bool>;
}
