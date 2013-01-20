//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.BlendMode;
import flambe.platform.html.WebGLTypes;
import flambe.platform.shader.DrawImageGL;
import flambe.platform.shader.DrawPatternGL;
import flambe.platform.shader.FillRectGL;
import flambe.platform.shader.ShaderGL;

class WebGLBatcher
{
    public var data (default, null) :Float32Array;

    public function new (gl :RenderingContext)
    {
        _gl = gl;

        _vertexBuffer = _gl.createBuffer();
        _gl.bindBuffer(_gl.ARRAY_BUFFER, _vertexBuffer);

        _quadIndexBuffer = _gl.createBuffer();
        _gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _quadIndexBuffer);

        _drawImageShader = new DrawImageGL(gl);
        _drawPatternShader = new DrawPatternGL(gl);
        _fillRectShader = new FillRectGL(gl);

        resize(16);
    }

    public function willRender ()
    {
        // _gl.clear(_gl.COLOR_BUFFER_BIT);
    }

    public function didRender ()
    {
        flush();
    }

    public function prepareDrawImage (blendMode :BlendMode, texture :WebGLTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, blendMode, _drawImageShader);
    }

    public function prepareDrawPattern (blendMode :BlendMode, texture :WebGLTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, blendMode, _drawPatternShader);
    }

    public function prepareFillRect (blendMode :BlendMode) :Int
    {
        return prepareQuad(6, blendMode, _fillRectShader);
    }

    private function prepareQuad (elementsPerVertex :Int,
        blendMode :BlendMode, shader :ShaderGL) :Int
    {
        if (blendMode != _lastBlendMode) {
            flush();
            _lastBlendMode = blendMode;
        }
        if (shader != _lastShader) {
            flush();
            _lastShader = shader;
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

        if (_lastBlendMode != _currentBlendMode) {
            switch (_lastBlendMode) {
                case Normal: _gl.blendFunc(_gl.ONE, _gl.ONE_MINUS_SRC_ALPHA);
                case Add: _gl.blendFunc(_gl.ONE, _gl.ONE);
                // TODO(bruno): Disable blending entirely?
                case CopyExperimental: _gl.blendFunc(_gl.ONE, _gl.ZERO);
            }
            _currentBlendMode = _lastBlendMode;
        }

        if (_lastTexture != _currentTexture) {
            _gl.bindTexture(_gl.TEXTURE_2D, _lastTexture.nativeTexture);
            _currentTexture = _lastTexture;
        }

        if (_lastShader != _currentShader) {
            _lastShader.useProgram();
            _lastShader.prepare();
            _currentShader = _lastShader;
        }

        switch (_lastShader) {
        case cast _drawPatternShader:
            _drawPatternShader.setMaxUV(_lastTexture.maxU, _lastTexture.maxV);
        }

        _gl.bufferSubData(_gl.ARRAY_BUFFER, 0, data.subarray(0, _dataOffset));
        _gl.drawElements(_gl.TRIANGLES, 6*_quads, _gl.UNSIGNED_SHORT, 0);

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
        _gl.bufferData(_gl.ARRAY_BUFFER,
            data.length*Float32Array.BYTES_PER_ELEMENT, _gl.STREAM_DRAW);

        var indices = new Uint16Array(6*maxQuads);
        for (ii in 0...maxQuads) {
            indices[ii*6 + 0] = ii*4 + 0;
            indices[ii*6 + 1] = ii*4 + 1;
            indices[ii*6 + 2] = ii*4 + 2;
            indices[ii*6 + 3] = ii*4 + 2;
            indices[ii*6 + 4] = ii*4 + 3;
            indices[ii*6 + 5] = ii*4 + 0;
        }
        _gl.bufferData(_gl.ELEMENT_ARRAY_BUFFER, indices, _gl.STATIC_DRAW);
    }

    private static inline var MAX_ELEMENTS_PER_VERTEX = 6;
    private static inline var MAX_BATCH_QUADS = 1024;

    private var _gl :RenderingContext;

    // Used to keep track of context changes requiring a flush
    private var _lastBlendMode :BlendMode = null;
    private var _lastShader :ShaderGL = null;
    private var _lastTexture :WebGLTexture = null;

    // Used to avoid redundant GL calls
    private var _currentBlendMode :BlendMode = null;
    private var _currentShader :ShaderGL = null;
    private var _currentTexture :WebGLTexture = null;

    private var _vertexBuffer :Buffer;
    private var _quadIndexBuffer :Buffer;

    private var _drawImageShader :DrawImageGL;
    private var _drawPatternShader :DrawPatternGL;
    private var _fillRectShader :FillRectGL;

    private var _quads :Int = 0;
    private var _maxQuads :Int = 0;
    private var _dataOffset :Int = 0;
}
