//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.platform.shader.DrawImage;
import flambe.platform.shader.DrawPattern;
import flambe.platform.shader.FillRect;
import flambe.util.Assert;

class Stage3DGraphics
    implements Graphics
{
    public function new (context3D :Context3D, batcher :Stage3DBatcher,
        renderTarget :Stage3DTexture)
    {
        _context3D = context3D;
        _batcher = batcher;
        _renderTarget = renderTarget;

        // Call reset() to set the size first
        // _stateList = new DrawingState();
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

        state.matrix.copyFrom(current.matrix);
        state.alpha = current.alpha;
        state.blendMode = current.blendMode;
        _stateList = state;
    }

    public function translate (x :Float, y :Float)
    {
        var state = getTopState();
        state.matrix.prependTranslation(x, y, 0);
    }

    public function scale (x :Float, y :Float)
    {
        if (x == 0 || y == 0) {
            return; // Flash throws an undocumented error if appendScale params are zero
        }
        var state = getTopState();
        state.matrix.prependScale(x, y, 1);
    }

    public function rotate (rotation :Float)
    {
        var state = getTopState();
        state.matrix.prependRotation(rotation, Vector3D.Z_AXIS);
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        var state = getTopState();
        var scratch = _scratchTransformVector;
        scratch[0*4 + 0] = m00;
        scratch[0*4 + 1] = m10;
        scratch[1*4 + 0] = m01;
        scratch[1*4 + 1] = m11;
        scratch[3*4 + 0] = m02;
        scratch[3*4 + 1] = m12;
        _scratchMatrix3D.copyRawDataFrom(scratch);
        state.matrix.prepend(_scratchMatrix3D);
    }

    public function restore ()
    {
        Assert.that(_stateList.prev != null, "Can't restore without a previous save");
        _stateList = _stateList.prev;
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
    {
        drawSubImage(texture, destX, destY, 0, 0, texture.width, texture.height);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var texture = Lib.as(texture, Stage3DTexture);
        var state = getTopState();

        var x1 = destX;
        var y1 = destY;
        var x2 = x1 + sourceW;
        var y2 = y1 + sourceH;
        var scratch = _scratchQuadVector;

        scratch[0] = x1;
        scratch[1] = y1;
        // scratch[2] = 0;

        scratch[3] = x2;
        scratch[4] = y1;
        // scratch[5] = 0;

        scratch[6] = x2;
        scratch[7] = y2;
        // scratch[8] = 0;

        scratch[9] = x1;
        scratch[10] = y2;
        // scratch[11] = 0;

        state.matrix.transformVectors(scratch, scratch);

        var offset = _batcher.prepareDrawImage(_renderTarget, state.blendMode, texture);
        var data = _batcher.data;
        var alpha = state.alpha;
        var w = texture.width;
        var h = texture.height;
        var u1 = texture.maxU*sourceX / w;
        var v1 = texture.maxV*sourceY / h;
        var u2 = texture.maxU*(sourceX + sourceW) / w;
        var v2 = texture.maxV*(sourceY + sourceH) / h;

        data[  offset] = scratch[0];
        data[++offset] = scratch[1];
        data[++offset] = u1;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = scratch[3];
        data[++offset] = scratch[4];
        data[++offset] = u2;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = scratch[6];
        data[++offset] = scratch[7];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = scratch[9];
        data[++offset] = scratch[10];
        data[++offset] = u1;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        var texture = Lib.as(texture, Stage3DTexture);
        var state = getTopState();
        var x2 = x + width;
        var y2 = y + height;
        var scratch = _scratchQuadVector;

        scratch[0] = x;
        scratch[1] = y;
        // scratch[2] = 0;

        scratch[3] = x2;
        scratch[4] = y;
        // scratch[5] = 0;

        scratch[6] = x2;
        scratch[7] = y2;
        // scratch[8] = 0;

        scratch[9] = x;
        scratch[10] = y2;
        // scratch[11] = 0;

        state.matrix.transformVectors(scratch, scratch);

        var offset = _batcher.prepareDrawPattern(_renderTarget, state.blendMode, texture);
        var data = _batcher.data;
        var u2 = texture.maxU * (width / texture.width);
        var v2 = texture.maxV * (height / texture.height);
        var alpha = state.alpha;

        data[  offset] = scratch[0];
        data[++offset] = scratch[1];
        data[++offset] = 0;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = scratch[3];
        data[++offset] = scratch[4];
        data[++offset] = u2;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = scratch[6];
        data[++offset] = scratch[7];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = scratch[9];
        data[++offset] = scratch[10];
        data[++offset] = 0;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        var x2 = x + width;
        var y2 = y + height;
        var scratch = _scratchQuadVector;

        scratch[0] = x;
        scratch[1] = y;
        // scratch[2] = 0;

        scratch[3] = x2;
        scratch[4] = y;
        // scratch[5] = 0;

        scratch[6] = x2;
        scratch[7] = y2;
        // scratch[8] = 0;

        scratch[9] = x;
        scratch[10] = y2;
        // scratch[11] = 0;

        state.matrix.transformVectors(scratch, scratch);

        var offset = _batcher.prepareFillRect(_renderTarget, state.blendMode);
        var data = _batcher.data;
        var r = (color & 0xff0000) / 0xff0000;
        var g = (color & 0x00ff00) / 0x00ff00;
        var b = (color & 0x0000ff) / 0x0000ff;
        var a = state.alpha;

        data[  offset] = scratch[0];
        data[++offset] = scratch[1];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = scratch[3];
        data[++offset] = scratch[4];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = scratch[6];
        data[++offset] = scratch[7];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = scratch[9];
        data[++offset] = scratch[10];
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

    public function reset (width :Int, height :Int)
    {
        // Reinitialize the stack from an orthographic projection matrix
        _stateList = new DrawingState();
        _stateList.matrix = new Matrix3D(Vector.ofArray([
            2/width, 0, 0, 0,
            0, -2/height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private static var _scratchMatrix3D = new Matrix3D();
    private static var _scratchQuadVector = new Vector<Float>(12, true);
    private static var _scratchTransformVector = (function () {
        var v = new Vector<Float>(16, true);
        new Matrix3D().copyRawDataTo(v);
        return v;
    })();

    private var _context3D :Context3D;
    private var _batcher :Stage3DBatcher;
    private var _renderTarget :Stage3DTexture;

    private var _stateList :DrawingState;
}

private class DrawingState
{
    public var matrix :Matrix3D;
    public var alpha :Float;
    public var blendMode :BlendMode;

    public var prev :DrawingState;
    public var next :DrawingState;

    public function new ()
    {
        matrix = new Matrix3D();
        alpha = 1;
        blendMode = Normal;
    }
}
