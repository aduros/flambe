//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.*;
import js.html.webgl.*;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.math.Rectangle;
import flambe.util.Assert;

class WebGLGraphics
    implements InternalGraphics
{
    public function new (batcher :WebGLBatcher, renderTarget :WebGLTextureRoot)
    {
        // Initialize this here to prevent blowing up during static init on browsers without typed
        // array support
        if (_scratchQuadArray == null) {
            _scratchQuadArray = new Float32Array(8);
        }

        _batcher = batcher;
        _renderTarget = renderTarget;
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

        current.matrix.clone(state.matrix);
        state.alpha = current.alpha;
        state.blendMode = current.blendMode;
        state.scissor = (current.scissor != null) ? current.scissor.clone(state.scissor) : null;
        _stateList = state;
    }

    public function translate (x :Float, y :Float)
    {
        var matrix = getTopState().matrix;
        matrix.m02 += matrix.m00*x + matrix.m01*y;
        matrix.m12 += matrix.m10*x + matrix.m11*y;
    }

    public function scale (x :Float, y :Float)
    {
        var matrix = getTopState().matrix;
        matrix.m00 *= x;
        matrix.m10 *= x;
        matrix.m01 *= y;
        matrix.m11 *= y;
    }

    public function rotate (rotation :Float)
    {
        var matrix = getTopState().matrix;
        rotation = FMath.toRadians(rotation);
        var sin = Math.sin(rotation);
        var cos = Math.cos(rotation);
        var m00 = matrix.m00;
        var m10 = matrix.m10;
        var m01 = matrix.m01;
        var m11 = matrix.m11;

        matrix.m00 = m00*cos + m01*sin;
        matrix.m10 = m10*cos + m11*sin;
        matrix.m01 = m01*cos - m00*sin;
        matrix.m11 = m11*cos - m10*sin;
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        var state = getTopState();
        _scratchMatrix.set(m00, m10, m01, m11, m02, m12);
        Matrix.multiply(state.matrix, _scratchMatrix, state.matrix);
    }

    public function restore ()
    {
        Assert.that(_stateList.prev != null, "Can't restore without a previous save");
        _stateList = _stateList.prev;
    }

    public function drawTexture (texture :Texture, x :Float, y :Float)
    {
        drawSubTexture(texture, x, y, 0, 0, texture.width, texture.height);
    }

    public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var state = getTopState();
        var texture :WebGLTexture = cast texture;
        var root = texture.root;
        root.assertNotDisposed();

        var pos = transformQuad(destX, destY, sourceW, sourceH);
        var rootWidth = root.width;
        var rootHeight = root.height;
        var u1 = (texture.rootX+sourceX) / rootWidth;
        var v1 = (texture.rootY+sourceY) / rootHeight;
        var u2 = u1 + sourceW/rootWidth;
        var v2 = v1 + sourceH/rootHeight;
        var alpha = state.alpha;

        var offset = _batcher.prepareDrawTexture(_renderTarget, state.blendMode, state.scissor, texture);
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = u1;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = pos[2];
        data[++offset] = pos[3];
        data[++offset] = u2;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = pos[4];
        data[++offset] = pos[5];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = pos[6];
        data[++offset] = pos[7];
        data[++offset] = u1;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        var texture :WebGLTexture = cast texture;
        var root = texture.root;
        root.assertNotDisposed();

        var pos = transformQuad(x, y, width, height);
        var u2 = width / root.width;
        var v2 = height / root.height;
        var alpha = state.alpha;

        var offset = _batcher.prepareDrawPattern(_renderTarget, state.blendMode, state.scissor, texture);
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = 0;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = pos[2];
        data[++offset] = pos[3];
        data[++offset] = u2;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = pos[4];
        data[++offset] = pos[5];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = pos[6];
        data[++offset] = pos[7];
        data[++offset] = 0;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();

        var pos = transformQuad(x, y, width, height);
        var r = (color & 0xff0000) / 0xff0000;
        var g = (color & 0x00ff00) / 0x00ff00;
        var b = (color & 0x0000ff) / 0x0000ff;
        var a = state.alpha;

        var offset = _batcher.prepareFillRect(_renderTarget, state.blendMode, state.scissor);
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = pos[2];
        data[++offset] = pos[3];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = pos[4];
        data[++offset] = pos[5];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = pos[6];
        data[++offset] = pos[7];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;
    }

    public function multiplyAlpha (factor :Float)
    {
        getTopState().alpha *= factor;
    }

    public function setAlpha (alpha :Float)
    {
        getTopState().alpha = alpha;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        getTopState().blendMode = blendMode;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        var rect = _scratchQuadArray;
        rect[0] = x;
        rect[1] = y;
        rect[2] = x + width;
        rect[3] = y + height;

        state.matrix.transformArray(cast rect, 4, cast rect);
        _inverseProjection.transformArray(cast rect, 4, cast rect);

        x = rect[0];
        y = rect[1];
        width = rect[2] - x;
        height = rect[3] - y;

        // Handle negative rectangles
        if (width < 0) {
            x += width;
            width = -width;
        }
        if (height < 0) {
            y += height;
            height = -height;
        }

        state.applyScissor(x, y, width, height);
    }

    public function willRender ()
    {
        _batcher.willRender();
    }

    public function didRender ()
    {
        _batcher.didRender();
    }

    public function onResize (width :Int, height :Int)
    {
        _stateList = new DrawingState();

        // Framebuffers need to be vertically flipped
        var flip = (_renderTarget != null) ? -1 : 1;
        _stateList.matrix.set(2/width, 0, 0, flip * -2/height, -1, flip);

        // May be used to transform back into screen coordinates
        _inverseProjection = new Matrix();
        _inverseProjection.set(2/width, 0, 0, 2/height, -1, -1);
        _inverseProjection.invert();
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private function transformQuad (x :Float, y :Float, width :Float, height :Float) :Float32Array
    {
        var x2 = x + width;
        var y2 = y + height;
        var pos = _scratchQuadArray;

        pos[0] = x;
        pos[1] = y;

        pos[2] = x2;
        pos[3] = y;

        pos[4] = x2;
        pos[5] = y2;

        pos[6] = x;
        pos[7] = y2;

        getTopState().matrix.transformArray(cast pos, 8, cast pos);
        return pos;
    }

    private static var _scratchMatrix = new Matrix();
    private static var _scratchQuadArray :Float32Array = null;

    private var _batcher :WebGLBatcher;
    private var _renderTarget :WebGLTextureRoot;

    private var _inverseProjection :Matrix = null;
    private var _stateList :DrawingState = null;
}

private class DrawingState
{
    public var matrix :Matrix;
    public var alpha :Float;
    public var blendMode :BlendMode;
    public var scissor :Rectangle = null;

    public var prev :DrawingState = null;
    public var next :DrawingState = null;

    public function new ()
    {
        matrix = new Matrix();
        alpha = 1;
        blendMode = Normal;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        if (scissor != null) {
            // Intersection with the previous scissor rectangle
            var x1 = FMath.max(scissor.x, x);
            var y1 = FMath.max(scissor.y, y);
            var x2 = FMath.min(scissor.x + scissor.width, x + width);
            var y2 = FMath.min(scissor.y + scissor.height, y + height);
            x = x1;
            y = y1;
            width = x2 - x1;
            height = y2 - y1;
        } else {
            scissor = new Rectangle();
        }
        scissor.set(Math.round(x), Math.round(y), Math.round(width), Math.round(height));
    }
}
