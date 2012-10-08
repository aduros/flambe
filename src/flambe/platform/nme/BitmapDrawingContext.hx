//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Shape;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

import haxe.FastList;

import flambe.display.BlendMode;
import flambe.display.DrawingContext;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.util.Assert;

class BitmapDrawingContext
    implements DrawingContext
{
    public function new (buffer :BitmapData)
    {
        _buffer = buffer;
        _stateList = new DrawingState();
        _shape = new Shape();
        _pixel = new BitmapData(1, 1, false);
        _scratchRect = new Rectangle();
        _scratchPoint = new Point();
        _scratchMatrix = new Matrix();
    }

    public function save ()
    {
        var current = _stateList;
        var state = _stateList.next;

        if (state == null) {
            // Grow the list
            state = new DrawingState();
            state.prev = current;
            current.next = state;
        }

#if flash11
        state.matrix.copyFrom(current.matrix);
#else
        var to = state.matrix, from = current.matrix;
        to.a = from.a; to.c = from.c; to.tx = from.tx;
        to.b = from.b; to.d = from.d; to.ty = from.ty;
#end
        state.color.alphaMultiplier = current.color.alphaMultiplier;
        state.blendMode = current.blendMode;
        _stateList = state;
    }

    public function translate (x :Float, y :Float)
    {
        flushGraphics();

        var matrix = getTopState().matrix;
        matrix.tx += matrix.a*x + matrix.c*y;
        matrix.ty += matrix.b*x + matrix.d*y;
    }

    public function scale (x :Float, y :Float)
    {
        flushGraphics();

        var matrix = getTopState().matrix;
        matrix.a *= x;
        matrix.b *= x;
        matrix.c *= y;
        matrix.d *= y;
    }

    public function rotate (rotation :Float)
    {
        flushGraphics();

        var matrix = getTopState().matrix;
        rotation = FMath.toRadians(rotation);
        var sin = Math.sin(rotation);
        var cos = Math.cos(rotation);
        var a = matrix.a;
        var b = matrix.b;
        var c = matrix.c;
        var d = matrix.d;

        matrix.a = a*cos + c*sin;
        matrix.b = b*cos + d*sin;
        matrix.c = c*cos - a*sin;
        matrix.d = d*cos - b*sin;
    }

    public function restore ()
    {
        Assert.that(_stateList.prev != null, "Can't restore without a previous save");
        flushGraphics();
        _stateList = _stateList.prev;
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
    {
        blit(texture, destX, destY, null);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        _scratchRect.x = sourceX;
        _scratchRect.y = sourceY;
        _scratchRect.width = sourceW;
        _scratchRect.height = sourceH;
        blit(texture, destX, destY, _scratchRect);
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        beginGraphics();

        var flashTexture = Lib.as(texture, NMETexture);
        _graphics.beginBitmapFill(flashTexture.bitmapData);
        _graphics.drawRect(x, y, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        flushGraphics();

        var state = getTopState();
        var matrix = state.matrix;

        // Does this matrix not involve rotation or blending?
        if (matrix.b == 0 && matrix.c == 0 && state.blendMode == null) {
            var scaleX = matrix.a;
            var scaleY = matrix.d;
            var rect = _scratchRect;
            rect.x = matrix.tx + x*scaleX;
            rect.y = matrix.ty + y*scaleY;
            rect.width = width*scaleX;
            rect.height = height*scaleY;

            // fillRect and colorTransform don't support negative rectangles
            if (rect.width < 0) {
                rect.width = -rect.width;
                rect.x -= rect.width;
            }
            if (rect.height < 0) {
                rect.height = -rect.height;
                rect.y -= rect.height;
            }

            // If we don't need to alpha blend, use fillRect(), otherwise colorTransform()
            if (state.color.alphaMultiplier == 1) {
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
            // Fall back to slowpoke draw() to draw a scaled and translated pixel
            _scratchMatrix.a = width;
            _scratchMatrix.b = 0;
            _scratchMatrix.c = 0;
            _scratchMatrix.d = height;
            _scratchMatrix.tx = x;
            _scratchMatrix.ty = y;
            _scratchMatrix.concat(matrix);

            _pixel.setPixel(0, 0, color);
            _buffer.draw(_pixel, _scratchMatrix, state.color, state.blendMode);
        }
    }

    public function multiplyAlpha (factor :Float)
    {
        flushGraphics();

        var state = getTopState();
        state.color.alphaMultiplier *= factor;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        var state = getTopState();
        switch (blendMode) {
            case Normal: state.blendMode = null;
            case Add: state.blendMode = nme.display.BlendMode.ADD;
        };
    }

    private function blit (texture :Texture, destX :Float, destY :Float, sourceRect :Rectangle)
    {
        flushGraphics();

        var flashTexture = Lib.as(texture, NMETexture);
        var state = getTopState();
        var matrix = state.matrix;

        // Use the faster copyPixels() if possible
        // TODO(bruno): Use approximately equals?
        if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1
                && state.color.alphaMultiplier == 1 && state.blendMode == null) {

            if (sourceRect == null) {
                sourceRect = _scratchRect;
                sourceRect.x = 0;
                sourceRect.y = 0;
                sourceRect.width = flashTexture.width;
                sourceRect.height = flashTexture.height;
            }
            _scratchPoint.x = matrix.tx + destX;
            _scratchPoint.y = matrix.ty + destY;
            _buffer.copyPixels(flashTexture.bitmapData, sourceRect, _scratchPoint);

        } else {
            var copy = null;
            if (destX != 0 || destY != 0) {
                // TODO(bruno): Optimize?
                copy = matrix.clone();
                translate(destX, destY);
            }
            if (sourceRect != null) {
                // BitmapData.draw() doesn't support a source rect, so we have to use a temp
                // (contrary to the docs, clipRect is relative to the target, not the source)
                if (sourceRect.width > 0 && sourceRect.height > 0) {
                    // TODO(bruno): Optimize?
                    var scratch = new BitmapData(
                        Std.int(sourceRect.width), Std.int(sourceRect.height),
                        flashTexture.bitmapData.transparent);
                    _scratchPoint.x = 0;
                    _scratchPoint.y = 0;
                    scratch.copyPixels(flashTexture.bitmapData, sourceRect, _scratchPoint);
                    _buffer.draw(scratch, matrix, state.color, state.blendMode, null, true);
                    scratch.dispose();
                }
            } else {
                _buffer.draw(flashTexture.bitmapData, matrix,
                    state.color, state.blendMode, null, true);
            }
            if (copy != null) {
                state.matrix = copy;
            }
        }
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private function flushGraphics ()
    {
        // If we're in vector graphics mode, push it out to the screen buffer
        if (_graphics != null) {
            var state = getTopState();
            _buffer.draw(_shape, state.matrix, state.color, state.blendMode, null, true);
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

    private var _stateList :DrawingState;
    private var _buffer :BitmapData;

    // The shape used for all rendering that can't be done with a BitmapData
    private var _shape :Shape;

    // The vector graphic commands pending drawing, or null if we're not in vector graphics mode
    private var _graphics :Graphics;

    // A 1x1 BitmapData used to optimize fillRect's worst-case
    private var _pixel :BitmapData;

    // Reusable instances to avoid tons of allocation
    private var _scratchPoint :Point;
    private var _scratchRect :Rectangle;
    private var _scratchMatrix :Matrix;
}

private class DrawingState
{
    public var matrix :Matrix;
    public var color :ColorTransform;
    public var blendMode :nme.display.BlendMode;

    public var prev :DrawingState;
    public var next :DrawingState;

    public function new ()
    {
        matrix = new Matrix();
        color = new ColorTransform();
    }
}
