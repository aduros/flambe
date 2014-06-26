//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Lib;
import flash.Vector;
import flash.display3D.Context3D;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.util.Assert;

class Stage3DGraphics
    implements InternalGraphics
{
    public function new (batcher :Stage3DBatcher, renderTarget :Stage3DTextureRoot)
    {
        _batcher = batcher;
        _renderTarget = renderTarget;

        // Call onResize() to set the size first
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
        state.scissorEnabled = current.scissorEnabled;
        if (state.scissorEnabled) {
            state.scissor.copyFrom(current.scissor);
        }
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

    public function drawTexture (texture :Texture, destX :Float, destY :Float)
    {
        drawSubTexture(texture, destX, destY, 0, 0, texture.width, texture.height);
    }

    public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var state = getTopState();
        if (state.emptyScissor()) {
            return;
        }
        var texture = Lib.as(texture, Stage3DTexture);
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

        var offset = _batcher.prepareDrawTexture(_renderTarget, state.blendMode, state.getScissor(), texture);
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = u1;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = pos[3];
        data[++offset] = pos[4];
        data[++offset] = u2;
        data[++offset] = v1;
        data[++offset] = alpha;

        data[++offset] = pos[6];
        data[++offset] = pos[7];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = pos[9];
        data[++offset] = pos[10];
        data[++offset] = u1;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        if (state.emptyScissor()) {
            return;
        }
        var texture = Lib.as(texture, Stage3DTexture);
        var root = texture.root;
        root.assertNotDisposed();

        var pos = transformQuad(x, y, width, height);
        var u2 = width / root.width;
        var v2 = height / root.height;
        var alpha = state.alpha;

        var offset = _batcher.prepareDrawPattern(_renderTarget, state.blendMode, state.getScissor(), texture);
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = 0;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = pos[3];
        data[++offset] = pos[4];
        data[++offset] = u2;
        data[++offset] = 0;
        data[++offset] = alpha;

        data[++offset] = pos[6];
        data[++offset] = pos[7];
        data[++offset] = u2;
        data[++offset] = v2;
        data[++offset] = alpha;

        data[++offset] = pos[9];
        data[++offset] = pos[10];
        data[++offset] = 0;
        data[++offset] = v2;
        data[++offset] = alpha;
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        if (state.emptyScissor()) {
            return;
        }

        var pos = transformQuad(x, y, width, height);
        var r = (color & 0xff0000) / 0xff0000;
        var g = (color & 0x00ff00) / 0x00ff00;
        var b = (color & 0x0000ff) / 0x0000ff;
        var a = state.alpha;

        var offset = _batcher.prepareFillRect(_renderTarget, state.blendMode, state.getScissor());
        var data = _batcher.data;

        data[  offset] = pos[0];
        data[++offset] = pos[1];
        data[++offset] = r;
        data[++offset] = g;
        data[++offset] = b;
        data[++offset] = a;

        data[++offset] = pos[3];
        data[++offset] = pos[4];
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

        data[++offset] = pos[9];
        data[++offset] = pos[10];
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
        var rect = _scratchClipVector;
        rect[0] = x;
        rect[1] = y;
        // rect[2] = 0;
        rect[3] = x + width;
        rect[4] = y + height;
        // rect[5] = 0;

        state.matrix.transformVectors(rect, rect);
        _inverseProjection.transformVectors(rect, rect);

        x = rect[0];
        y = rect[1];
        width = rect[3] - x;
        height = rect[4] - y;

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
        var ortho = new Matrix3D(Vector.ofArray([
            2/width, 0, 0, 0,
            0, -2/height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));

        // Reinitialize the stack from an orthographic projection matrix
        _stateList = new DrawingState();
        _stateList.matrix = ortho;

        // May be used to transform back into screen coordinates
        _inverseProjection = ortho.clone();
        _inverseProjection.invert();
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private function transformQuad (x :Float, y :Float, width :Float, height :Float) :Vector<Float>
    {
        var x2 = x + width;
        var y2 = y + height;
        var pos = _scratchQuadVector;

        pos[0] = x;
        pos[1] = y;
        // pos[2] = 0;

        pos[3] = x2;
        pos[4] = y;
        // pos[5] = 0;

        pos[6] = x2;
        pos[7] = y2;
        // pos[8] = 0;

        pos[9] = x;
        pos[10] = y2;
        // pos[11] = 0;

        getTopState().matrix.transformVectors(pos, pos);
        return pos;
    }

    private static var _scratchMatrix3D = new Matrix3D();
    private static var _scratchClipVector = new Vector<Float>(2*3, true);
    private static var _scratchQuadVector = new Vector<Float>(4*3, true);
    private static var _scratchTransformVector = (function () {
        var v = new Vector<Float>(16, true);
        new Matrix3D().copyRawDataTo(v);
        return v;
    })();

    private var _batcher :Stage3DBatcher;
    private var _renderTarget :Stage3DTextureRoot;

    private var _inverseProjection :Matrix3D;
    private var _stateList :DrawingState;
}

private class DrawingState
{
    public var matrix :Matrix3D;
    public var alpha :Float;
    public var blendMode :BlendMode;

    public var scissor :Rectangle;
    public var scissorEnabled :Bool;

    public var prev :DrawingState;
    public var next :DrawingState;

    public function new ()
    {
        matrix = new Matrix3D();
        alpha = 1;
        blendMode = Normal;
        scissor = new Rectangle();
    }

    public function getScissor () :Rectangle
    {
        return scissorEnabled ? scissor : null;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        if (scissorEnabled) {
            // Intersection with the previous scissor rectangle
            var x1 = FMath.max(scissor.x, x);
            var y1 = FMath.max(scissor.y, y);
            var x2 = FMath.min(scissor.x + scissor.width, x + width);
            var y2 = FMath.min(scissor.y + scissor.height, y + height);
            x = x1;
            y = y1;
            width = x2 - x1;
            height = y2 - y1;
        }
        scissor.setTo(x, y, width, height);
        scissorEnabled = true;
    }

    /**
     * Whether the scissor region is empty. Calling Context3D.setScissorRectangle with an empty
     * rectangle actually disables scissor testing, so this needs to be queried before every draw
     * method.
     */
    public function emptyScissor () :Bool
    {
        return scissorEnabled && (scissor.width < 0.5 || scissor.height < 0.5);
    }
}
