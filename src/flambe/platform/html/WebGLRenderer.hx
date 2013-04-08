//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.webgl.RenderingContext;

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
        batcher = new WebGLBatcher(gl);
        _graphics = new WebGLGraphics(gl, batcher);

        gl.clearColor(1, 1, 1, 1);
        gl.enable(GL.BLEND);
        gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

        stage.resize.connect(onResize);
        onResize();
    }

    public function createTexture (image :Dynamic) :WebGLTexture
    {
        var texture = createEmptyTexture(image.width, image.height);
        texture.uploadImageData(image);
        return texture;
    }

    public function createEmptyTexture (width :Int, height :Int) :WebGLTexture
    {
        return new WebGLTexture(this, width, height);
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

        gl.viewport(0, 0, width, height);
        _graphics.reset(width, height);
    }

    private var _graphics :WebGLGraphics;
}
