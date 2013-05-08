//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.CanvasElement;
import js.html.Uint8Array;
import js.html.webgl.*;

import haxe.io.Bytes;

import flambe.display.Graphics;
import flambe.display.Texture;

class WebGLTexture
    implements Texture
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var graphics (get, null) :Graphics;

    public var nativeTexture (default, null) :js.html.webgl.Texture;
    public var framebuffer :Framebuffer = null;

    // The UV texture coordinates for the bottom right corner of the image. These are less than one
    // if the texture had to be resized to a power of 2.
    public var maxU (default, null) :Float;
    public var maxV (default, null) :Float;

    public function new (renderer :WebGLRenderer, width :Int, height :Int)
    {
        _renderer = renderer;
        _width = width;
        _height = height;

        _widthPow2 = nextPowerOfTwo(width);
        _heightPow2 = nextPowerOfTwo(height);

        maxU = width / _widthPow2;
        maxV = height / _heightPow2;

        var gl = renderer.gl;
        nativeTexture = gl.createTexture();
        renderer.batcher.bindTexture(nativeTexture);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    }

    public function uploadImageData (image :Dynamic)
    {
        if (_widthPow2 != image.width || _heightPow2 != image.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = HtmlUtil.createEmptyCanvas(_widthPow2, _heightPow2);
            resized.getContext2d().drawImage(image, 0, 0);
            drawBorder(resized, image.width, image.height);
            image = resized;
        }

        _renderer.batcher.bindTexture(nativeTexture);
        var gl = _renderer.gl;
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_NEAREST);
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
        gl.generateMipmap(GL.TEXTURE_2D);
    }

    public function clear ()
    {
        _renderer.batcher.bindTexture(nativeTexture);
        var gl = _renderer.gl;
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, _widthPow2, _heightPow2,
            0, GL.RGBA, GL.UNSIGNED_BYTE, null);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        get_graphics(); // Ensure we have a framebuffer
        _renderer.batcher.bindFramebuffer(framebuffer);

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
        _renderer.batcher.bindTexture(nativeTexture);

        // Can't update a texture used by a bound framebuffer apparently
        _renderer.batcher.bindFramebuffer(null);

        // TODO(bruno): Avoid the redundant Uint8Array copy
        var gl = _renderer.gl;
        gl.texSubImage2D(GL.TEXTURE_2D, 0, x, y, sourceW, sourceH,
            GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array(pixels.getData()));
    }

    inline private function get_width () :Int
    {
        return _width;
    }

    inline private function get_height () :Int
    {
        return _height;
    }

    private function get_graphics () :Graphics
    {
        if (_graphics == null) {
            _graphics = new WebGLGraphics(_renderer.batcher, this);
            _graphics.reset(width, height);

            var gl = _renderer.gl;
            framebuffer = gl.createFramebuffer();
            _renderer.batcher.bindFramebuffer(framebuffer);
            gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0,
                GL.TEXTURE_2D, nativeTexture, 0);
        }
        return _graphics;
    }

    private static function nextPowerOfTwo (n :Int) :Int
    {
        var p = 1;
        while (p < n) {
            p <<= 1;
        }
        return p;
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

    private var _width :Int;
    private var _height :Int;

    private var _widthPow2 :Int;
    private var _heightPow2 :Int;

    private var _graphics :WebGLGraphics = null;
}
