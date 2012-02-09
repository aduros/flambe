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
import flambe.platform.shader.FillRect;

class Stage3DDrawingContext
    implements DrawingContext
{
    public function new (context3D :Context3D)
    {
        _context3D = context3D;
#if flambe_dev
        _context3D.enableErrorChecking = true;
#end

        _stack = new FastList<DrawingState>();
        _scratchVector3D = new Vector3D();

        var stage = Lib.current.stage;
        _projMatrix = createOrthoMatrix(stage.stageWidth, stage.stageHeight);

        // Four vertices in a quad, with 4 floats for each vertex (x, y, u, v)
        _quadVector = new Vector<Float>(4*4, true);
        _quadVerts = _context3D.createVertexBuffer(4, 4);

        // The index buffer for a quad is created once and never changes
        var indices :Array<UInt> = [ 0, 1, 2, 2, 3, 0 ];
        _quadIndices = _context3D.createIndexBuffer(6);
        _quadIndices.uploadFromVector(Vector.ofArray(indices), 0, 6);

        _drawImageShader = new DrawImage(_context3D);
        _fillRectShader = new FillRect(_context3D);
    }

    public function save ()
    {
        var copy = new DrawingState();

        if (_stack.isEmpty()) {
            copy.alpha = 1;
            copy.matrix = new Matrix3D();
            applyBlendMode(Normal);

        } else {
            var state = getTopState();
            copy.matrix = state.matrix.clone();
            copy.alpha = state.alpha;
            copy.blendMode = state.blendMode;
        }

        _stack.add(copy);
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
        var old = _stack.pop();

        // Restore the new current blend mode if necessary
        if (!_stack.isEmpty()) {
            var state = getTopState();
            if (state.blendMode != old.blendMode) {
                applyBlendMode(state.blendMode);
            }
        }
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
    {
        var flashTexture :FlashTexture = cast texture;

        var x2 = destX + texture.width;
        var y2 = destY + texture.height;
        var vector = _quadVector;

        vector[0] = destX;
        vector[1] = destY;
        vector[2] = 0;
        vector[3] = 0;

        vector[4] = x2;
        vector[5] = destY;
        vector[6] = flashTexture.maxU;
        vector[7] = 0;

        vector[8] = x2;
        vector[9] = y2;
        vector[10] = flashTexture.maxU;
        vector[11] = flashTexture.maxV;

        vector[12] = destX;
        vector[13] = y2;
        vector[14] = 0;
        vector[15] = flashTexture.maxV;

        _quadVerts.uploadFromVector(vector, 0, 4);

        var state = getTopState();
        _drawImageShader.init({
            model: state.matrix,
            proj: _projMatrix,
        }, {
            texture: flashTexture.nativeTexture,
            alpha: state.alpha,
        });

        _drawImageShader.bind(_quadVerts);

        // TODO(bruno): Batch multiple quads that use the same texture and alpha into a single
        // drawTriangles
        _context3D.drawTriangles(_quadIndices);

        _drawImageShader.unbind();
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var flashTexture :FlashTexture = cast texture;

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

        var vector = _quadVector;

        vector[0] = x1;
        vector[1] = y1;
        vector[2] = u1;
        vector[3] = v1;

        vector[4] = x2;
        vector[5] = y1;
        vector[6] = u2;
        vector[7] = v1;

        vector[8] = x2;
        vector[9] = y2;
        vector[10] = u2;
        vector[11] = v2;

        vector[12] = x1;
        vector[13] = y2;
        vector[14] = u1;
        vector[15] = v2;

        _quadVerts.uploadFromVector(vector, 0, 4);

        var state = getTopState();
        _drawImageShader.init({
            model: state.matrix,
            proj: _projMatrix,
        }, {
            texture: flashTexture.nativeTexture,
            alpha: state.alpha,
        });

        _drawImageShader.bind(_quadVerts);

        // TODO(bruno): Batch multiple quads that use the same texture and alpha into a single
        // drawTriangles call
        _context3D.drawTriangles(_quadIndices);

        _drawImageShader.unbind();
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        // Not yet implemented
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        var x2 = x + width;
        var y2 = y + height;
        var vector = _quadVector;

        vector[0] = x;
        vector[1] = y;
        vector[2] = 0;
        vector[3] = 0;

        vector[4] = x2;
        vector[5] = y;
        vector[6] = 0;
        vector[7] = 0;

        vector[8] = x2;
        vector[9] = y2;
        vector[10] = 0;
        vector[11] = 0;

        vector[12] = x;
        vector[13] = y2;
        vector[14] = 0;
        vector[15] = 0;

        _quadVerts.uploadFromVector(vector, 0, 4);

        // Load the color into the scratch vector
        _scratchVector3D.x = ((color>>16) & 0xff) / 255.0;
        _scratchVector3D.y = ((color>>8) & 0xff) / 255.0;
        _scratchVector3D.z = (color & 0xff) / 255.0;
        _scratchVector3D.w = state.alpha;

        _fillRectShader.init({
            model: state.matrix,
            proj: _projMatrix,
        }, {
            color: _scratchVector3D,
        });

        _fillRectShader.bind(_quadVerts);

        // TODO(bruno): Batch multiple quads that use the same color and alpha into a single
        // drawTriangles call
        _context3D.drawTriangles(_quadIndices);

        _fillRectShader.unbind();
    }

    public function multiplyAlpha (factor :Float)
    {
        getTopState().alpha *= factor;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        if (blendMode != Normal) {
            getTopState().blendMode = blendMode;
        }
        applyBlendMode(blendMode);
    }

    inline private function getTopState () :DrawingState
    {
        return _stack.head.elt;
    }

    private function applyBlendMode (blendMode :BlendMode)
    {
        if (blendMode == null) {
            blendMode = Normal;
        }

        switch (blendMode) {
        case Normal:
            _context3D.setBlendFactors(SOURCE_ALPHA, ONE_MINUS_SOURCE_ALPHA);
        case Add:
            _context3D.setBlendFactors(ONE, ONE);
        }
    }

    private static function createOrthoMatrix (width :Int, height :Int) :Matrix3D
    {
        var m = new Vector<Float>(16, true);
        m[0] = 2 / width;
        m[1] = m[2] = m[3] = m[4] = 0;
        m[5] = -2 / height;
        m[6] = m[7] = m[8] = m[9] = 0;
        m[10] = -1.0;
        m[11] = 0;
        m[12] = -1;
        m[13] = 1;
        m[14] = 0;
        m[15] = 1;
        return new Matrix3D(m);
    }

    private var _context3D :Context3D;

    private var _stack :FastList<DrawingState>;
    private var _scratchVector3D :Vector3D;
    private var _projMatrix :Matrix3D;

    private var _quadVector :Vector<Float>;
    private var _quadVerts :VertexBuffer3D;
    private var _quadIndices :IndexBuffer3D;

    private var _drawImageShader :DrawImage;
    private var _fillRectShader :FillRect;
}

private class DrawingState
{
    public var matrix :Matrix3D;
    public var alpha :Float;
    public var blendMode :BlendMode;

    public function new () { }
}
