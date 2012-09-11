//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;

import haxe.FastList;

import flambe.display.BlendMode;
import flambe.display.DrawingContext;
import flambe.display.Texture;
import flambe.platform.shader.DrawImage;
import flambe.platform.shader.DrawPattern;
import flambe.platform.shader.FillRect;
import flambe.util.Assert;

class Stage3DDrawingContext
    implements DrawingContext
{
    public function new (context3D :Context3D)
    {
        _context3D = context3D;
#if flambe_debug_renderer
        _context3D.enableErrorChecking = true;
#end

        _stateList = new DrawingState();
        _scratchVector = new Vector<Float>(12, true);
        _scratchVector3D = new Vector3D();

        _drawImageShader = new DrawImage(_context3D);
        _drawPatternShader = new DrawPattern(_context3D);

        // TODO(bruno): _singleIndices contains indices for one quad. This shouldn't be necessary,
        // we should just be able to reuse the first 6 elements of _batchIndices, but I can't seem
        // to get drawTriangles to accept a sliced index buffer. It wants to use the entire thing
        // every time. Perhaps test this on different hardware.
        var v = new Vector<UInt>(6, true);
        v[0] = 0; v[1] = 1; v[2] = 2; v[3] = 2; v[4] = 3; v[5] = 0;
        _singleIndices = _context3D.createIndexBuffer(6);
        _singleIndices.uploadFromVector(v, 0, 6);

        _fillRectShader = new FillRect(_context3D);
        _fillRectVerts = _context3D.createVertexBuffer(4, 2);

        _batchData = new Vector<Float>(0, true);
        expandBatch();
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

    public function restore ()
    {
        Assert.that(_stateList.prev != null, "Can't restore without a previous save");
        _stateList = _stateList.prev;
    }

    private function addQuadToBatch ()
    {
        if (_quads >= MAX_BATCH_QUADS) {
            flushBatch();
            return 0;
        }

        var offset = _quads*4*ELEMENTS_PER_VERTEX;
        if (offset >= cast _batchData.length) {
            expandBatch();
        }
        ++_quads;
        return offset;
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
    {
        drawSubImage(texture, destX, destY, 0, 0, texture.width, texture.height);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var flashTexture :FlashTexture = cast texture;
        if (_nextTexture != flashTexture) {
            flushBatch();
            _nextTexture = flashTexture;
        }

        var state = getTopState();
        if (state.blendMode != _nextBlendMode) {
            flushBatch();
            _nextBlendMode = state.blendMode;
        }

        var w = texture.width;
        var h = texture.height;

        var x1 = destX;
        var y1 = destY;
        var u1 = flashTexture.maxU*sourceX / w;
        var v1 = flashTexture.maxV*sourceY / h;

        var x2 = x1 + sourceW;
        var y2 = y1 + sourceH;
        var u2 = flashTexture.maxU*(sourceX + sourceW) / w;
        var v2 = flashTexture.maxV*(sourceY + sourceH) / h;

        var scratch = _scratchVector;

        scratch[0] = x1;
        scratch[1] = y1;
        scratch[2] = 0;

        scratch[3] = x2;
        scratch[4] = y1;
        scratch[5] = 0;

        scratch[6] = x2;
        scratch[7] = y2;
        scratch[8] = 0;

        scratch[9] = x1;
        scratch[10] = y2;
        scratch[11] = 0;

        state.matrix.transformVectors(scratch, scratch);

        var offset = addQuadToBatch();
        var data = _batchData;
        var alpha = state.alpha;

        data[offset] = scratch[0];
        data[offset+1] = scratch[1];
        data[offset+2] = u1;
        data[offset+3] = v1;
        data[offset+4] = alpha;

        data[offset+5] = scratch[3];
        data[offset+6] = scratch[4];
        data[offset+7] = u2;
        data[offset+8] = v1;
        data[offset+9] = alpha;

        data[offset+10] = scratch[6];
        data[offset+11] = scratch[7];
        data[offset+12] = u2;
        data[offset+13] = v2;
        data[offset+14] = alpha;

        data[offset+15] = scratch[9];
        data[offset+16] = scratch[10];
        data[offset+17] = u1;
        data[offset+18] = v2;
        data[offset+19] = alpha;
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        flushBatch();

        var flashTexture :FlashTexture = cast texture;
        var state = getTopState();
        var alpha = state.alpha;
        var scratch = _scratchVector;
        var x2 = x + width;
        var y2 = y + height;
        var u = flashTexture.maxU * (width / flashTexture.width);
        var v = flashTexture.maxV * (height / flashTexture.height);

        var data = _batchData;
        data[0] = x;
        data[1] = y;
        data[2] = 0;
        data[3] = 0;
        data[4] = alpha;

        data[5] = x2;
        data[6] = y;
        data[7] = u;
        data[8] = 0;
        data[9] = alpha;

        data[10] = x2;
        data[11] = y2;
        data[12] = u;
        data[13] = v;
        data[14] = alpha;

        data[15] = x;
        data[16] = y2;
        data[17] = 0;
        data[18] = v;
        data[19] = alpha;

        var maxUV = _scratchVector3D;
        maxUV.x = flashTexture.maxU;
        maxUV.y = flashTexture.maxV;
        maxUV.z = 0;
        maxUV.w = 0;

        _drawPatternShader.init({
            model: state.matrix,
            proj: _projMatrix,
        }, {
            texture: flashTexture.nativeTexture,
            maxUV: maxUV,
        });

        _batchVerts.uploadFromVector(data, 0, 4);
        _drawPatternShader.bind(_batchVerts);

        // TODO(bruno): Batching similar patterns?
        _context3D.drawTriangles(_batchIndices, 0, 2);

        _drawPatternShader.unbind();
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        flushBatch();

        var state = getTopState();
        var scratch = _scratchVector;
        var x2 = x + width;
        var y2 = y + height;

        scratch[0] = x;
        scratch[1] = y;
        scratch[2] = x2;
        scratch[3] = y;
        scratch[4] = x2;
        scratch[5] = y2;
        scratch[6] = x;
        scratch[7] = y2;

        var color4 = _scratchVector3D;
        color4.x = ((color>>16) & 0xff) / 255.0;
        color4.y = ((color>>8) & 0xff) / 255.0;
        color4.z = (color & 0xff) / 255.0;
        color4.w = state.alpha;

        _fillRectShader.init({
            model: state.matrix,
            proj: _projMatrix,
        }, {
            color: color4,
        });

        _fillRectVerts.uploadFromVector(scratch, 0, 4);
        _fillRectShader.bind(_fillRectVerts);

        // TODO(bruno): Batch multiple common fillRects into a single draw call
        // _context3D.drawTriangles(_batchIndices, 0, 2);
        _context3D.drawTriangles(_singleIndices);

        _fillRectShader.unbind();
    }

    public function multiplyAlpha (factor :Float)
    {
        getTopState().alpha *= factor;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        getTopState().blendMode = blendMode;
    }

    public function willRender ()
    {
        // Context3D requires clear() be called before each frame
        _context3D.clear(1.0, 1.0, 1.0);
    }

    public function didRender ()
    {
        flushBatch();
        _context3D.present();
#if flambe_debug_renderer
        trace("==================");
#end
    }

    public function resize (width :Int, height :Int)
    {
        // TODO(bruno): Vary anti-alias quality depending on the environment
        _context3D.configureBackBuffer(width, height, 2, false);

        // Create an orthographic projection matrix
        _projMatrix = new Matrix3D(Vector.ofArray([
            2/width, 0, 0, 0,
            0, -2/height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));
    }

    private function expandBatch ()
    {
        var oldSize = Std.int(_batchData.length/(4*ELEMENTS_PER_VERTEX));
        var newSize = (oldSize == 0) ? 16 : 2*oldSize;

        _batchData.fixed = false;
        _batchData.length = 4*ELEMENTS_PER_VERTEX*newSize;
        _batchData.fixed = true;

        var indices = new Vector<UInt>(6*newSize, true);
        for (ii in 0...newSize) {
            indices[ii*6] = ii*4;
            indices[ii*6 + 1] = ii*4 + 1;
            indices[ii*6 + 2] = ii*4 + 2;
            indices[ii*6 + 3] = ii*4 + 2;
            indices[ii*6 + 4] = ii*4 + 3;
            indices[ii*6 + 5] = ii*4;
        }

        if (_batchIndices != null) {
            _batchIndices.dispose();
        }
        _batchIndices = _context3D.createIndexBuffer(indices.length);
        _batchIndices.uploadFromVector(indices, 0, indices.length);

        if (_batchVerts != null) {
            _batchVerts.dispose();
        }
        _batchVerts = _context3D.createVertexBuffer(4*newSize, ELEMENTS_PER_VERTEX);

#if flambe_debug_renderer
        trace("Expanded batch to " + newSize);
#end
    }

    private function flushBatch ()
    {
        if (_quads < 1) {
            return;
        }

#if flambe_debug_renderer
        trace("Flushing batch of " + _quads + " quads");
#end

        if (_nextBlendMode != null) {
            switch (_nextBlendMode) {
            case Normal:
                _context3D.setBlendFactors(SOURCE_ALPHA, ONE_MINUS_SOURCE_ALPHA);
            case Add:
                _context3D.setBlendFactors(ONE, ONE);
            }
        }

        _drawImageShader.init({
            proj: _projMatrix,
        }, {
            texture: _nextTexture.nativeTexture,
        });

        // Can't seem to be able to upload only the part of _batchData that we care about, so upload
        // the whole damn thing. Hrmm.
        // _batchVerts.uploadFromVector(_batchData, 0, _quads*4);
        _batchVerts.uploadFromVector(_batchData, 0, Std.int(_batchData.length/ELEMENTS_PER_VERTEX));
        _drawImageShader.bind(_batchVerts);

        _context3D.drawTriangles(_batchIndices, 0, 2*_quads);

        _drawImageShader.unbind();
        _quads = 0;
        _nextTexture = null;
        _nextBlendMode = null;
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private static inline var ELEMENTS_PER_VERTEX = 5;
    private static inline var MAX_BATCH_QUADS = 256;

    private var _context3D :Context3D;

    private var _stateList :DrawingState;
    private var _scratchVector3D :Vector3D;
    private var _scratchVector :Vector<Float>;
    private var _projMatrix :Matrix3D;

    private var _batchData :Vector<Float>;
    private var _batchVerts :VertexBuffer3D;
    private var _batchIndices :IndexBuffer3D;
    private var _drawImageShader :DrawImage;
    private var _drawPatternShader :DrawPattern;

    private var _singleIndices :IndexBuffer3D;
    private var _fillRectVerts :VertexBuffer3D;
    private var _fillRectShader :FillRect;

    private var _quads :Int;
    private var _nextTexture :FlashTexture;
    private var _nextBlendMode :BlendMode;
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
