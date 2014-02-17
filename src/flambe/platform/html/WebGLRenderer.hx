//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.webgl.*;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.util.Assert;

class WebGLRenderer
    implements Renderer
{
    public var graphics :InternalGraphics;

    public var gl (default, null) :RenderingContext;
    public var batcher (default, null) :WebGLBatcher;

    public function new (stage :HtmlStage, gl :RenderingContext)
    {
        this.gl = gl;

        // Handle GL context loss
        gl.canvas.addEventListener("webglcontextlost", function (event) {
            event.preventDefault();
            Log.warn("WebGL context lost");
            System.hasGPU._ = false;
        }, false);
        gl.canvas.addEventListener("webglcontextrestore", function (event) {
            Log.warn("WebGL context restored");
            init();
        }, false);

        stage.resize.connect(onResize);
        init();
    }

    public function createTexture (image :Dynamic) :WebGLTexture
    {
        if (gl.isContextLost()) {
            return null;
        }
        var root = new WebGLTextureRoot(this, image.width, image.height);
        root.uploadImageData(image);
        return root.createTexture(image.width, image.height);
    }

    public function createEmptyTexture (width :Int, height :Int) :WebGLTexture
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

    public function getName () :String
    {
        return "WebGL";
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
        System.hasGPU._ = true;
    }
}
