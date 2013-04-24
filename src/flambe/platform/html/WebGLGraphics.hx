//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.*;
import js.html.webgl.*;
import js.html.webgl.RenderingContext;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.util.Assert;

class WebGLGraphics
    implements Graphics
{
    public function new (batcher :WebGLBatcher, renderTarget :WebGLTexture)
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
        _stateList = state;
    }

    public function translate (x :Float, y :Float)
    {
        throw "TODO";
    }

    public function scale (x :Float, y :Float)
    {
        throw "TODO";
    }

    public function rotate (rotation :Float)
    {
        throw "TODO";
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

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
        drawSubImage(texture, x, y, 0, 0, texture.width, texture.height);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var state = getTopState();
        var texture :WebGLTexture = cast texture;

        var pos = transformQuad(destX, destY, sourceW, sourceH);
        var w = texture.width;
        var h = texture.height;
        var u1 = texture.maxU*sourceX / w;
        var v1 = texture.maxV*sourceY / h;
        var u2 = texture.maxU*(sourceX + sourceW) / w;
        var v2 = texture.maxV*(sourceY + sourceH) / h;
        var alpha = state.alpha;

        var offset = _batcher.prepareDrawImage(_renderTarget, state.blendMode, texture);
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

        var pos = transformQuad(x, y, width, height);
        var u2 = texture.maxU * (width / texture.width);
        var v2 = texture.maxV * (height / texture.height);
        var alpha = state.alpha;

        var offset = _batcher.prepareDrawPattern(_renderTarget, state.blendMode, texture);
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

        var offset = _batcher.prepareFillRect(_renderTarget, state.blendMode);
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
        throw "TODO";
    }

    public function reset (width :Int, height :Int)
    {
        _stateList = new DrawingState();

        // Framebuffers need to be vertically flipped
        var flip = (_renderTarget != null) ? -1 : 1;
        _stateList.matrix.set(2/width, 0, 0, flip * -2/height, -1, flip);
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
    private var _renderTarget :WebGLTexture;

    private var _stateList :DrawingState = null;
}

private class DrawingState
{
    public var matrix :Matrix;
    public var alpha :Float;
    public var blendMode :BlendMode;

    public var prev :DrawingState = null;
    public var next :DrawingState = null;

    public function new ()
    {
        matrix = new Matrix();
        alpha = 1;
        blendMode = Normal;
    }
}
