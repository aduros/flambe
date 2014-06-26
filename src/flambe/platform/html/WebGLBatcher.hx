//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.*;
import js.html.webgl.*;
import js.html.webgl.RenderingContext;

import flambe.display.BlendMode;
import flambe.math.Rectangle;
import flambe.platform.shader.DrawPatternGL;
import flambe.platform.shader.DrawTextureGL;
import flambe.platform.shader.FillRectGL;
import flambe.platform.shader.ShaderGL;

/**
 * Batches up geometry to glDrawElements and avoids redundant state changes. All GL state changes
 * MUST go through the batcher.
 */
class WebGLBatcher
{
    public var data (default, null) :Float32Array;

    public function new (gl :RenderingContext)
    {
        _gl = gl;

        gl.clearColor(0, 0, 0, 0);
        gl.enable(GL.BLEND);
        gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

        _vertexBuffer = gl.createBuffer();
        gl.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);

        _quadIndexBuffer = gl.createBuffer();
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _quadIndexBuffer);

        _drawTextureShader = new DrawTextureGL(gl);
        _drawPatternShader = new DrawPatternGL(gl);
        _fillRectShader = new FillRectGL(gl);

        resize(16);
    }

    public function resizeBackbuffer (width :Int, height :Int)
    {
        _gl.viewport(0, 0, width, height);
        _backbufferWidth = width;
        _backbufferHeight = height;
    }

    public function willRender ()
    {
#if flambe_transparent
        _gl.clear(GL.COLOR_BUFFER_BIT);
#end
    }

    public function didRender ()
    {
        flush();
    }

    /** Safely bind a texture. */
    public function bindTexture (texture :Texture)
    {
        flush();
        _lastTexture = null;
        _currentTexture = null;

        _gl.bindTexture(GL.TEXTURE_2D, texture);
    }

    /** Safely delete a texture. */
    public function deleteTexture (texture :WebGLTextureRoot)
    {
        // If we have unflushed quads that use this texture, flush them now
        if (_lastTexture != null && _lastTexture.root == texture) {
            flush();
            _lastTexture = null;
            _currentTexture = null;
        }

        _gl.deleteTexture(texture.nativeTexture);
    }

    /** Safely bind a framebuffer. */
    public function bindFramebuffer (texture :WebGLTextureRoot)
    {
        if (texture != _lastRenderTarget) {
            flush();
            bindRenderTarget(texture);
        }
    }

    /** Safely delete a framebuffer. */
    public function deleteFramebuffer (texture :WebGLTextureRoot)
    {
        // If we have unflushed quads that render to this texture, flush them now
        if (texture == _lastRenderTarget) {
            flush();
            _lastRenderTarget = null;
            _currentRenderTarget = null;
        }

        _gl.deleteFramebuffer(texture.framebuffer);
    }

    public function prepareDrawTexture (renderTarget :WebGLTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, texture :WebGLTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, scissor, _drawTextureShader);
    }

    public function prepareDrawPattern (renderTarget :WebGLTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, texture :WebGLTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, scissor, _drawPatternShader);
    }

    public function prepareFillRect (renderTarget :WebGLTextureRoot,
        blendMode :BlendMode, scissor :Rectangle) :Int
    {
        return prepareQuad(6, renderTarget, blendMode, scissor, _fillRectShader);
    }

    private function prepareQuad (elementsPerVertex :Int, renderTarget :WebGLTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, shader :ShaderGL) :Int
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

        // Handle changes to the scissor rectangle
        if (scissor != null || _lastScissor != null) {
            if (scissor == null || _lastScissor == null || !_lastScissor.equals(scissor)) {
                flush();
                _lastScissor = (scissor != null) ? scissor.clone(_lastScissor) : null;
                _pendingSetScissor = true;
            }
        }

        if (_quads >= _maxQuads) {
            resize(2*_maxQuads);
        }
        ++_quads;

        var offset = _dataOffset;
        _dataOffset += 4*elementsPerVertex;
        return offset;
    }

    private function flush ()
    {
        if (_quads < 1) {
            return;
        }

        if (_lastRenderTarget != _currentRenderTarget) {
            bindRenderTarget(_lastRenderTarget);
        }

        if (_lastBlendMode != _currentBlendMode) {
            switch (_lastBlendMode) {
                case Normal: _gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
                case Add: _gl.blendFunc(GL.ONE, GL.ONE);
                case Mask: _gl.blendFunc(GL.ZERO, GL.SRC_ALPHA);
                // TODO(bruno): Disable blending entirely?
                case Copy: _gl.blendFunc(GL.ONE, GL.ZERO);
            }
            _currentBlendMode = _lastBlendMode;
        }

        if (_pendingSetScissor) {
            if (_lastScissor != null) {
                _gl.enable(GL.SCISSOR_TEST);
                _gl.scissor(Std.int(_lastScissor.x), Std.int(_lastScissor.y),
                    Std.int(_lastScissor.width), Std.int(_lastScissor.height));
            } else {
                _gl.disable(GL.SCISSOR_TEST);
            }
            _pendingSetScissor = false;
        }

        if (_lastTexture != _currentTexture) {
            _gl.bindTexture(GL.TEXTURE_2D, _lastTexture.root.nativeTexture);
            _currentTexture = _lastTexture;
        }

        if (_lastShader != _currentShader) {
            _lastShader.useProgram();
            _lastShader.prepare();
            _currentShader = _lastShader;
        }

        if (_lastShader == _drawPatternShader) {
            var texture = _lastTexture;
            var root = texture.root;
            _drawPatternShader.setRegion(
                texture.rootX / root.width,
                texture.rootY / root.height,
                texture.width / root.width,
                texture.height / root.height);
        }

        // _gl.bufferSubData(GL.ARRAY_BUFFER, 0, data.subarray(0, _dataOffset));
        _gl.bufferData(GL.ARRAY_BUFFER, data.subarray(0, _dataOffset), GL.STREAM_DRAW);
        _gl.drawElements(GL.TRIANGLES, 6*_quads, GL.UNSIGNED_SHORT, 0);

        _quads = 0;
        _dataOffset = 0;
    }

    private function resize (maxQuads :Int)
    {
        flush();
        if (maxQuads > MAX_BATCH_QUADS) {
            return; // That's big enough, return right after the flush
        }

        _maxQuads = maxQuads;

        // Set the new vertex buffer size
        data = new Float32Array(maxQuads*4*MAX_ELEMENTS_PER_VERTEX);
        _gl.bufferData(GL.ARRAY_BUFFER,
            data.length*Float32Array.BYTES_PER_ELEMENT, GL.STREAM_DRAW);

        var indices = new Uint16Array(6*maxQuads);
        for (ii in 0...maxQuads) {
            indices[ii*6 + 0] = ii*4 + 0;
            indices[ii*6 + 1] = ii*4 + 1;
            indices[ii*6 + 2] = ii*4 + 2;
            indices[ii*6 + 3] = ii*4 + 2;
            indices[ii*6 + 4] = ii*4 + 3;
            indices[ii*6 + 5] = ii*4 + 0;
        }
        _gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
    }

    private function bindRenderTarget (texture :WebGLTextureRoot)
    {
        // Bind the texture framebuffer, or the original backbuffer
        if (texture != null) {
            _gl.bindFramebuffer(GL.FRAMEBUFFER, texture.framebuffer);
            _gl.viewport(0, 0, texture.width, texture.height);
        } else {
            _gl.bindFramebuffer(GL.FRAMEBUFFER, null);
            _gl.viewport(0, 0, _backbufferWidth, _backbufferHeight);
        }
        _currentRenderTarget = texture;
        _lastRenderTarget = texture;
    }

    private static inline var MAX_ELEMENTS_PER_VERTEX = 6;
    private static inline var MAX_BATCH_QUADS = 1024;

    private var _gl :RenderingContext;

    // Used to keep track of context changes requiring a flush
    private var _lastBlendMode :BlendMode = null;
    private var _lastRenderTarget :WebGLTextureRoot = null;
    private var _lastShader :ShaderGL = null;
    private var _lastTexture :WebGLTexture = null;
    private var _lastScissor :Rectangle = null;

    // Used to avoid redundant GL calls
    private var _currentBlendMode :BlendMode = null;
    private var _currentShader :ShaderGL = null;
    private var _currentTexture :WebGLTexture = null;
    private var _currentRenderTarget :WebGLTextureRoot = null;
    private var _pendingSetScissor :Bool = false;

    private var _vertexBuffer :Buffer;
    private var _quadIndexBuffer :Buffer;

    private var _drawTextureShader :DrawTextureGL;
    private var _drawPatternShader :DrawPatternGL;
    private var _fillRectShader :FillRectGL;

    private var _quads :Int = 0;
    private var _maxQuads :Int = 0;
    private var _dataOffset :Int = 0;

    private var _backbufferWidth :Int = 0;
    private var _backbufferHeight :Int = 0;
}
