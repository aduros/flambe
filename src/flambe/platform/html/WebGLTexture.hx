//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.webgl.RenderingContext;

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
    // public var framebuffer (default, null) :Framebuffer;

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
        gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_NEAREST);
    }

    public function uploadImageData (image :Dynamic)
    {
        if (_widthPow2 != image.width || _heightPow2 != image.height) {
            // Resize up to the next power of two, padding with transparent black
            var resized = HtmlUtil.createEmptyCanvas(_widthPow2, _heightPow2);
            resized.getContext("2d").drawImage(image, 0, 0);
            drawBorder(resized, image.width, image.height);
            image = resized;
        }

        var gl = _renderer.gl;
        _renderer.batcher.bindTexture(nativeTexture);
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
        gl.generateMipmap(GL.TEXTURE_2D);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        return throw "TODO";
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        return throw "TODO";
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
        return throw "TODO";
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
    private static function drawBorder (canvas :Dynamic, width :Int, height :Int)
    {
        // TODO
        //
        // // Right edge
        // bitmapData.copyPixels(bitmapData,
        //     new Rectangle(width-1, 0, 1, height), new Point(width, 0));

        // // Bottom edge
        // bitmapData.copyPixels(bitmapData,
        //     new Rectangle(0, height-1, width, 1), new Point(0, height));

        // // Is a one pixel border enough?
    }

    private var _width :Int;
    private var _height :Int;

    private var _widthPow2 :Int;
    private var _heightPow2 :Int;

    private var _renderer :WebGLRenderer;
    private var _graphics :WebGLGraphics;
}
