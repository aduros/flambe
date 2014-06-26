//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.CanvasElement;
import js.html.Uint8Array;
import js.html.webgl.*;

import haxe.io.Bytes;

import flambe.math.FMath;

class WebGLTextureRoot extends BasicAsset<WebGLTextureRoot>
    implements TextureRoot
{
    // The power of two dimensions of the texture
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    public var nativeTexture (default, null) :js.html.webgl.Texture;
    public var framebuffer :Framebuffer = null;

    public function new (renderer :WebGLRenderer, width :Int, height :Int)
    {
        super();
        _renderer = renderer;
        // 1 px textures cause weird DrawPattern sampling on some drivers
        this.width = FMath.max(2, MathUtil.nextPowerOfTwo(width));
        this.height = FMath.max(2, MathUtil.nextPowerOfTwo(height));

        var gl = renderer.gl;
        nativeTexture = gl.createTexture();
        renderer.batcher.bindTexture(nativeTexture);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    }

    public function createTexture (width :Int, height :Int) :WebGLTexture
    {
        return new WebGLTexture(this, width, height);
    }

    public function uploadImageData (image :Dynamic)
    {
        assertNotDisposed();

        if (width != image.width || height != image.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = HtmlUtil.createEmptyCanvas(width, height);
            resized.getContext2d().drawImage(image, 0, 0);
            drawBorder(resized, image.width, image.height);
            image = resized;
        }

        _renderer.batcher.bindTexture(nativeTexture);
        var gl = _renderer.gl;
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
    }

    public function clear ()
    {
        assertNotDisposed();

        _renderer.batcher.bindTexture(nativeTexture);
        var gl = _renderer.gl;
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        assertNotDisposed();

        getGraphics(); // Ensure we have a framebuffer
        _renderer.batcher.bindFramebuffer(this);

        var pixels = new Uint8Array(4*width*height);
        var gl = _renderer.gl;
        gl.readPixels(x, y, width, height, GL.RGBA, GL.UNSIGNED_BYTE, pixels);

        // Undo alpha premultiplication. This is lossy!
        var ii = 0, ll = pixels.length;
        while (ii < ll) {
            var invAlpha = 255 / pixels[ii+3];
            pixels[ii] = cast pixels[ii] * invAlpha;
            ++ii;
            pixels[ii] = cast pixels[ii] * invAlpha;
            ++ii;
            pixels[ii] = cast pixels[ii] * invAlpha;
            ii += 2; // Advance to next pixel
        }

        return Bytes.ofData(cast pixels);
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        assertNotDisposed();

        _renderer.batcher.bindTexture(nativeTexture);

        // Can't update a texture used by a bound framebuffer apparently
        _renderer.batcher.bindFramebuffer(null);

        // TODO(bruno): Avoid the redundant Uint8Array copy
        var gl = _renderer.gl;
        gl.texSubImage2D(GL.TEXTURE_2D, 0, x, y, sourceW, sourceH,
            GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array(pixels.getData()));
    }

    public function getGraphics () :WebGLGraphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            _graphics = new WebGLGraphics(_renderer.batcher, this);
            _graphics.onResize(width, height);

            var gl = _renderer.gl;
            framebuffer = gl.createFramebuffer();
            _renderer.batcher.bindFramebuffer(this);
            gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0,
                GL.TEXTURE_2D, nativeTexture, 0);
        }
        return _graphics;
    }

    override private function copyFrom (that :WebGLTextureRoot)
    {
        this.nativeTexture = that.nativeTexture;
        this.framebuffer = that.framebuffer;
        this.width = that.width;
        this.height = that.height;
        this._graphics = that._graphics;
    }

    override private function onDisposed ()
    {
        var batcher = _renderer.batcher;
        batcher.deleteTexture(this);
        if (framebuffer != null) {
            batcher.deleteFramebuffer(this);
        }

        nativeTexture = null;
        framebuffer = null;
        _graphics = null;
    }

    /**
     * Extends the right and bottom edge pixels of a bitmap. This is to prevent artifacts caused by
     * sampling the outer transparency when the edge pixels are sampled.
     */
    private static function drawBorder (canvas :CanvasElement, width :Int, height :Int)
    {
        var ctx = canvas.getContext2d();

        // Right edge
        ctx.drawImage(canvas, width-1, 0, 1, height, width, 0, 1, height);

        // Bottom edge
        ctx.drawImage(canvas, 0, height-1, width, 1, 0, height, width, 1);

        // Is a one pixel border enough?
    }

    private var _renderer :WebGLRenderer;
    private var _graphics :WebGLGraphics = null;
}
