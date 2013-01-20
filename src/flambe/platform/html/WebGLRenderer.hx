//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.platform.html.WebGLTypes;

// TODO(bruno): Handle GL context loss
// TODO(bruno): Handle canvas resize
class WebGLRenderer
    implements Renderer
{
    public var gl (default, null) :RenderingContext;
    public var batcher (default, null) :WebGLBatcher;

    public function new (gl :RenderingContext)
    {
        this.gl = gl;
        _graphics = new WebGLGraphics(gl);
        batcher = new WebGLBatcher(gl);

        gl.clearColor(1, 1, 1, 1);
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

    private var _graphics :WebGLGraphics;
}
