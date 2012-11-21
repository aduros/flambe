//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Vector;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Vector3D;

import format.hxsl.Shader;

import flambe.display.BlendMode;
import flambe.platform.shader.DrawImage;
import flambe.platform.shader.DrawPattern;
import flambe.platform.shader.FillRect;

class Stage3DBatcher
{
    public var data (default, null) :Vector<Float>;

    public function new (context3D :Context3D)
    {
        _context3D = context3D;
        _drawImageShader = new DrawImage(context3D);
        _drawPatternShader = new DrawPattern(context3D);
        _fillRectShader = new FillRect(context3D);
        resize(16);
    }

    public function willRender ()
    {
        // Switch to the back buffer
        if (_currentRenderTarget != null) {
#if flambe_debug_renderer
            trace("Resetting render target to back buffer");
#end
            flush();
            _context3D.setRenderToBackBuffer();
            _currentRenderTarget = null;
        }
        // And clear it as required by Stage3D
        _context3D.clear(1.0, 1.0, 1.0);
    }

    public function didRender ()
    {
        // Flush any remaining quads and present the back buffer
        flush();
        _context3D.present();

        _lastTexture = null;
        // _lastBlendMode = null;
        _lastShader = null;

        // present() resets the render target to the back buffer
        _currentRenderTarget = null;
    }

    /** Adds a quad to the batch, using the DrawImage shader. */
    public function prepareDrawImage (renderTarget :Stage3DTexture, blendMode :BlendMode,
        texture :Stage3DTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, _drawImageShader);
    }

    /** Adds a quad to the batch, using the DrawPattern shader. */
    public function prepareDrawPattern (renderTarget :Stage3DTexture, blendMode :BlendMode,
        texture :Stage3DTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, _drawPatternShader);
    }

    /** Adds a quad to the batch, using the FillRect shader. */
    public function prepareFillRect (renderTarget :Stage3DTexture, blendMode :BlendMode) :Int
    {
        return prepareQuad(6, renderTarget, blendMode, _fillRectShader);
    }

    private function prepareQuad (elementsPerVertex :Int, renderTarget :Stage3DTexture,
        blendMode :BlendMode, shader :Shader) :Int
    {
        if (renderTarget != _lastRenderTarget) {
            flush();
            _lastRenderTarget = renderTarget;
        }
        if (blendMode != _lastBlendMode) {
            flush();
            _lastBlendMode = blendMode;
        }
        if (shader != _lastShader) {
            flush();
            _lastShader = shader;
        }

        var offset;
        if (_quads >= MAX_BATCH_QUADS) {
            flush();
            offset = 0;
        } else {
            var elements = 4*elementsPerVertex;
            offset = _quads*elements;
            if (offset + elements >= Std.int(data.length)) {
                resize(2*_maxQuads);
            }
        }
        ++_quads;
        return offset;
    }

    private function flush ()
    {
        if (_quads < 1) {
            return;
        }

#if flambe_debug_renderer
        trace("Flushing " + _quads + " / " + _maxQuads + " quads");
#end

        if (_lastRenderTarget != _currentRenderTarget) {
#if flambe_debug_renderer
            trace("Changing render target: " + _lastRenderTarget);
#end
            if (_lastRenderTarget != null) {
                _context3D.setRenderToTexture(_lastRenderTarget.nativeTexture, false, 2);
            } else {
                _context3D.setRenderToBackBuffer();
            }
            _context3D.clear(0, 0, 0, 0); // Required :(
            _currentRenderTarget = _lastRenderTarget;
        }

        if (_lastBlendMode != _currentBlendMode) {
#if flambe_debug_renderer
            trace("Changing blend mode: " + _lastBlendMode);
#end
            switch (_lastBlendMode) {
                case Normal: _context3D.setBlendFactors(ONE, ONE_MINUS_SOURCE_ALPHA);
                case Add: _context3D.setBlendFactors(ONE, ONE);
                case CopyExperimental: _context3D.setBlendFactors(ONE, ZERO);
            }
            _currentBlendMode = _lastBlendMode;
        }

        var vertexBuffer = null;
        switch (_lastShader) {
        case cast _drawImageShader:
            _drawImageShader.init({}, {texture: _lastTexture.nativeTexture});
            vertexBuffer = _vertexBuffer5;

        case cast _drawPatternShader:
            var maxUV = _scratchVector3D;
            maxUV.x = _lastTexture.maxU;
            maxUV.y = _lastTexture.maxV;
            // maxUV.z = 0;
            // maxUV.w = 0;
            _drawPatternShader.init({}, {texture: _lastTexture.nativeTexture, maxUV: maxUV});
            vertexBuffer = _vertexBuffer5;

        case cast _fillRectShader:
            _fillRectShader.init({}, {});
            vertexBuffer = _vertexBuffer6;
        }

        // vertexBuffer.uploadFromVector(data, 0, _quads*4);
        vertexBuffer.uploadFromVector(data, 0, _maxQuads*4);
        _lastShader.bind(vertexBuffer);
        _context3D.drawTriangles(_quadIndices, 0, _quads*2);
        _lastShader.unbind();

        _quads = 0;
    }

    private function resize (maxQuads :Int)
    {
        _maxQuads = maxQuads;
        data = new Vector<Float>(maxQuads*4*MAX_ELEMENTS_PER_VERTEX, true);

        var indices = new Vector<UInt>(6*maxQuads, true);
        for (ii in 0...maxQuads) {
            indices[ii*6] = ii*4;
            indices[ii*6 + 1] = ii*4 + 1;
            indices[ii*6 + 2] = ii*4 + 2;
            indices[ii*6 + 3] = ii*4 + 2;
            indices[ii*6 + 4] = ii*4 + 3;
            indices[ii*6 + 5] = ii*4;
        }
        if (_quadIndices != null) {
            _quadIndices.dispose();
        }
        _quadIndices = _context3D.createIndexBuffer(indices.length);
        _quadIndices.uploadFromVector(indices, 0, indices.length);

        var verts = 4*maxQuads;
        _vertexBuffer5 = createVertexBuffer(verts, 5, _vertexBuffer5);
        _vertexBuffer6 = createVertexBuffer(verts, 6, _vertexBuffer6);
    }

    private function createVertexBuffer (verts :Int, elementsPerVertex :Int,
        oldBuffer :VertexBuffer3D) :VertexBuffer3D
    {
        if (oldBuffer != null) {
            oldBuffer.dispose();
        }
        return _context3D.createVertexBuffer(verts, elementsPerVertex);
    }

    private static inline var MAX_ELEMENTS_PER_VERTEX = 6;
    private static inline var MAX_BATCH_QUADS = 1024;

    private static var _scratchVector3D = new Vector3D();

    private var _context3D :Context3D;

    // Used to keep track of context changes requiring a flush
    private var _lastBlendMode :BlendMode;
    private var _lastRenderTarget :Stage3DTexture;
    private var _lastShader :Shader;
    private var _lastTexture :Stage3DTexture;

    // Used to avoid redundant Context3D calls
    private var _currentBlendMode :BlendMode;
    private var _currentRenderTarget :Stage3DTexture;

    private var _drawImageShader :DrawImage;
    private var _drawPatternShader :DrawPattern;
    private var _fillRectShader :FillRect;

    private var _quadIndices :IndexBuffer3D;
    private var _vertexBuffer5 :VertexBuffer3D;
    private var _vertexBuffer6 :VertexBuffer3D;

    private var _quads :Int;
    private var _maxQuads :Int;
}
