//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxe.FastList;

import flambe.display.Texture;
import flambe.math.FMath;

class FlashDrawingContext
    implements DrawingContext
{
    public function new (buffer :BitmapData)
    {
        _buffer = buffer;
        _stack = new FastList<DrawingState>();
        _shape = new Shape();
        _pixel = new BitmapData(1, 1, false);
    }

    public function save ()
    {
        var copy = new DrawingState();

        if (_stack.isEmpty()) {
            copy.matrix = new Matrix();
        } else {
            var state = getTopState();
            copy.matrix = state.matrix.clone();
            copy.color = state.color;
        }

        _stack.add(copy);
    }

    public function translate (x :Float, y :Float)
    {
        flushGraphics();

        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.translate(x, y);
        matrix.concat(copy);
    }

    public function scale (x :Float, y :Float)
    {
        flushGraphics();

        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.scale(x, y);
        matrix.concat(copy);
    }

    public function rotate (rotation :Float)
    {
        flushGraphics();

        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.rotate(FMath.toRadians(rotation));
        matrix.concat(copy);
    }

    public function restore ()
    {
        flushGraphics();
        _stack.pop();
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
    {
        blit(texture, destX, destY, null);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        blit(texture, destX, destY, new Rectangle(sourceX, sourceY, sourceW, sourceH));
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        beginGraphics();

        _graphics.beginBitmapFill(texture);
        _graphics.drawRect(x, y, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        flushGraphics();

        var state = getTopState();
        var matrix = state.matrix;

        // Does this matrix not involve rotation?
        if (matrix.b == 0 && matrix.c == 0) {
            var scaleX = matrix.a;
            var scaleY = matrix.d;
            var rect = new Rectangle(matrix.tx + x*scaleX, matrix.ty + y*scaleY,
                width*scaleX, height*scaleY);

            // If we don't need to alpha blend, use fillRect(), otherwise colorTransform()
            if (state.color == null) {
                _buffer.fillRect(rect, color);

            } else {
                var red = 0xff & (color >> 16);
                var green = 0xff & (color >> 8);
                var blue = 0xff & (color);
                var alpha = state.color.alphaMultiplier;
                var invAlpha = 1-alpha;
                var transform = new ColorTransform(invAlpha, invAlpha, invAlpha, 1,
                    alpha*red, alpha*green, alpha*blue);
                _buffer.colorTransform(rect, transform);
            }

        } else {
            // Fall back to slowpoke draw()
            var localMatrix = new Matrix();
            localMatrix.scale(width, height);
            localMatrix.translate(x, y);
            localMatrix.concat(matrix);
            _pixel.setPixel(0, 0, color);
            _buffer.draw(_pixel, localMatrix, state.color);
        }
    }

    public function multiplyAlpha (factor :Float)
    {
        flushGraphics();

        var state = getTopState();
        if (state.color == null) {
            state.color = new ColorTransform(1, 1, 1, factor);
        } else {
            state.color.alphaMultiplier *= factor;
        }
    }

    private function blit (texture :Texture, destX :Float, destY :Float, sourceRect :Rectangle)
    {
        flushGraphics();

        var state = getTopState();
        var matrix = state.matrix;

        // Use the faster copyPixels() if possible
        // TODO: Use approximately equals?
        if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1
                && state.color == null) {

            if (sourceRect == null) {
                sourceRect = new Rectangle(0, 0, texture.width, texture.height);
            }
            _buffer.copyPixels(texture,
                sourceRect, new Point(matrix.tx + destX, matrix.ty + destY));

        } else {
            matrix.tx += destX;
            matrix.ty += destY;
            if (sourceRect != null) {
                // BitmapData.draw() doesn't support a source rect, so we have to use a temp
                // (contrary to the docs, clipRect is relative to the target, not the source)
                var scratch = new BitmapData(
                    Std.int(sourceRect.width), Std.int(sourceRect.height), texture.transparent);
                scratch.copyPixels(texture, sourceRect, new Point(0, 0));
                _buffer.draw(scratch, matrix, state.color, null, null, true);
                scratch.dispose();
            } else {
                _buffer.draw(texture, matrix, state.color, null, null, true);
            }
            matrix.tx -= destX;
            matrix.ty -= destY;
        }
    }

    inline private function getTopState ()
    {
        return _stack.head.elt;
    }

    private function flushGraphics ()
    {
        // If we're in vector graphics mode, push it out to the screen buffer
        if (_graphics != null) {
            var state = getTopState();
            _buffer.draw(_shape, state.matrix, state.color, null, null, true);
            _graphics.clear();
            _graphics = null;
        }
    }

    inline private function beginGraphics ()
    {
        if (_graphics == null) {
            _graphics = _shape.graphics;
        }
    }

    private var _stack :FastList<DrawingState>;
    private var _buffer :BitmapData;

    // The shape used for all rendering that can't be done with a BitmapData
    private var _shape :Shape;

    // The vector graphic commands pending drawing, or null if we're not in vector graphics mode
    private var _graphics :Graphics;

    // A 1x1 BitmapData used to optimize fillRect's worst-case
    private var _pixel :BitmapData;
}

private class DrawingState
{
    public var matrix :Matrix;
    public var color :ColorTransform;

    public function new () { }
}
