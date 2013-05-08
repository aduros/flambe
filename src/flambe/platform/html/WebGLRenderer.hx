//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.webgl.*;

import flambe.display.Graphics;
import flambe.display.Texture;

// TODO(bruno): Handle GL context loss
class WebGLRenderer
    implements Renderer
{
    public var gl (default, null) :RenderingContext;
    public var batcher (default, null) :WebGLBatcher;

    public function new (stage :HtmlStage, gl :RenderingContext)
    {
        Log.info("Using experimental WebGL renderer", ["version", gl.getParameter(GL.VERSION)]);

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
        var texture = new WebGLTexture(this, image.width, image.height);
        texture.uploadImageData(image);
        return texture;
    }

    public function createEmptyTexture (width :Int, height :Int) :WebGLTexture
    {
        var texture = new WebGLTexture(this, width, height);
        texture.clear();
        return texture;
    }

    public function willRender () :Graphics
    {
        batcher.willRender();
        return _graphics;
    }

    public function didRender ()
    {
        batcher.didRender();
    }

    private function onResize ()
    {
        var width = gl.canvas.width;
        var height = gl.canvas.height;

        batcher.reset(width, height);
        _graphics.reset(width, height);
    }

    private function init ()
    {
        batcher = new WebGLBatcher(gl);
        _graphics = new WebGLGraphics(batcher, null);
        onResize();
        System.hasGPU._ = true;
    }

    private var _graphics :WebGLGraphics;
}
