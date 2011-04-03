package flambe.platform.flash;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Point;

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
        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.translate(x, y);
        matrix.concat(copy);
    }

    public function scale (x :Float, y :Float)
    {
        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.scale(x, y);
        matrix.concat(copy);
    }

    public function rotate (rotation :Float)
    {
        // TODO: Optimize
        var matrix = getTopState().matrix;
        var copy = matrix.clone();
        matrix.identity();
        matrix.rotate(FMath.toRadians(rotation));
        matrix.concat(copy);
    }

    public function restore ()
    {
        _stack.pop();
    }

    public function drawTexture (texture :Texture, x :Int, y :Int)
    {
        var state = getTopState();
        var matrix = state.matrix;

        // Use the faster copyPixels() if possible
        // TODO: Use approximately equals?
        if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1
                && state.color == null) {
            _buffer.copyPixels(texture, new Rectangle(0, 0, texture.width, texture.height),
                new Point(matrix.tx + x, matrix.ty + y));

        } else {
            state.matrix.tx += x;
            state.matrix.ty += y;
            _buffer.draw(texture, state.matrix, state.color, null, null, true);
            state.matrix.tx -= x;
            state.matrix.ty -= y;
        }
    }

    public function multiplyAlpha (alpha :Float)
    {
        if (alpha < 1) {
            var state = getTopState();
            if (state.color == null) {
                state.color = new ColorTransform(1, 1, 1, alpha);
            } else {
                state.color.alphaMultiplier *= alpha;
            }
        }
    }

    inline private function getTopState ()
    {
        return _stack.head.elt;
    }

    private var _stack :FastList<DrawingState>;
    private var _buffer :BitmapData;
}

private class DrawingState
{
    public var matrix :Matrix;
    public var color :ColorTransform;

    public function new () { }
}
