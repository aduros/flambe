//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.webgl.*;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

class WebGLRenderer
    implements InternalRenderer<Dynamic>
{
    public var type (get, null) :RendererType;
    public var maxTextureSize (get, null) :Int;
    public var hasGPU (get, null) :Value<Bool>;

    public var graphics :InternalGraphics;

    public var gl (default, null) :RenderingContext;
    public var batcher (default, null) :WebGLBatcher;

    public function new (stage :HtmlStage, gl :RenderingContext)
    {
        _hasGPU = new Value<Bool>(true);
        this.gl = gl;

        // Handle GL context loss
        gl.canvas.addEventListener("webglcontextlost", function (event) {
            event.preventDefault();
            Log.warn("WebGL context lost");
            _hasGPU._ = false;
        }, false);
        gl.canvas.addEventListener("webglcontextrestore", function (event) {
            Log.warn("WebGL context restored");
            init();
            _hasGPU._ = true;
        }, false);

        stage.resize.connect(onResize);
        init();
    }

    inline private function get_type () :RendererType
    {
        return WebGL;
    }

    private function get_maxTextureSize () :Int
    {
        return gl.getParameter(GL.MAX_TEXTURE_SIZE);
    }

    inline private function get_hasGPU () :Value<Bool>
    {
        return _hasGPU;
    }

    public function createTextureFromImage (image :Dynamic) :WebGLTexture
    {
        if (gl.isContextLost()) {
            return null;
        }
        var root = new WebGLTextureRoot(this, image.width, image.height);
        root.uploadImageData(image);
        return root.createTexture(image.width, image.height);
    }

    public function createTexture (width :Int, height :Int) :WebGLTexture
    {
        if (gl.isContextLost()) {
            return null;
        }
        var root = new WebGLTextureRoot(this, width, height);
        root.clear();
        return root.createTexture(width, height);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        // TODO(bruno): Detect supported texture extensions
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :WebGLTexture
    {
        if (gl.isContextLost()) {
            return null;
        }
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

    private function onResize ()
    {
        var width = gl.canvas.width, height = gl.canvas.height;
        batcher.resizeBackbuffer(width, height);
        graphics.onResize(width, height);
    }

    private function init ()
    {
        batcher = new WebGLBatcher(gl);
        graphics = new WebGLGraphics(batcher, null);
        onResize();
    }

    private var _hasGPU :Value<Bool>;
}
