//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Lib;
import flash.Vector;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

import hxsl.Shader;

import flambe.display.BlendMode;
import flambe.display.Material;
import flambe.platform.shader.ShaderHXSL;
import flambe.platform.shader.DrawPattern;
import flambe.platform.shader.DrawTexture;
import flambe.platform.shader.FillRect;
import flambe.util.Assert;

import flambe.platform.flash.Stage3DShaderManager;

class Stage3DBatcher
{
    public var data (default, null) :Vector<Float>;

    public function new (context3D :Context3D)
    {
        _context3D = context3D;
        _scratchScissor = new Rectangle();
        _shaderManager = new Stage3DShaderManager();

        resize(16);
    }

    public function resizeBackbuffer (width :Int, height :Int)
    {
        _context3D.configureBackBuffer(width, height, 2, false);
    }

    public function willRender ()
    {
        // Switch to the back buffer
        if (_currentRenderTarget != null) {
            flush();
#if flambe_debug_renderer
            trace("Resetting render target to back buffer");
#end
            _context3D.setRenderToBackBuffer();
            _currentRenderTarget = _lastRenderTarget = null;
        }
        // And clear it as required by Stage3D
        _context3D.clear(0, 0, 0);
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

    /** Safely delete a texture. */
    public function deleteTexture (texture :Stage3DTextureRoot)
    {
        // If we have unflushed quads that use this texture, flush them now
        if (_lastTexture != null && _lastTexture.root == texture) {
            flush();
            _lastTexture = null;
        }

        texture.nativeTexture.dispose();
    }

    /** Reads the pixels out from a texture. May return a BitmapData larger than requested. */
    public function readPixels (texture :Stage3DTextureRoot, x :Int, y :Int,
        width :Int, height :Int) :BitmapData
    {
        // Turns out Stage3D doesn't make it easy to get data out of a texture. So we have to:
        //   1. Resize the back buffer
        //   2. Draw the texture to the back buffer
        //   3. Call drawToBitmapData (which only works on the back buffer)
        //   4. Restore the back buffer
        //
        // Oy.

        // Flush any pending draws before the back buffer is messed with
        flush();

        // The minimum back buffer size is 50x50
        if (width < 50) width = 50;
        if (height < 50) height = 50;

        var scratch = new Vector<Float>(12, true);
        var x1 = -x;
        var y1 = -y;
        var x2 = x1 + texture.width;
        var y2 = y1 + texture.height;

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

        var ortho = new Matrix3D(Vector.ofArray([
            2/width, 0, 0, 0,
            0, -2/height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]));
        ortho.transformVectors(scratch, scratch);

        var offset = prepareDrawTexture(null, Copy, null,
            texture.createTexture(texture.width, texture.height));
        data[  offset] = scratch[0];
        data[++offset] = scratch[1];
        data[++offset] = 0;
        data[++offset] = 0;
        data[++offset] = 1;

        data[++offset] = scratch[3];
        data[++offset] = scratch[4];
        data[++offset] = 1;
        data[++offset] = 0;
        data[++offset] = 1;

        data[++offset] = scratch[6];
        data[++offset] = scratch[7];
        data[++offset] = 1;
        data[++offset] = 1;
        data[++offset] = 1;

        data[++offset] = scratch[9];
        data[++offset] = scratch[10];
        data[++offset] = 0;
        data[++offset] = 1;
        data[++offset] = 1;

        // Create a temporary back buffer of the given size, and draw the texture on it
        _context3D.configureBackBuffer(width, height, 2, false);
        _context3D.setRenderToBackBuffer();
        _context3D.clear(0, 0, 0, 0);
        _lastRenderTarget = _currentRenderTarget = null;
        flush();

        // Read out the temporary back buffer
        var pixels = new BitmapData(width, height);
        _context3D.drawToBitmapData(pixels);

        // Restore the back buffer to its previous state
        var stage = Lib.current.stage;
        _context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
        _context3D.clear(0, 0, 0);

        return pixels;
    }

    /** Register a new shader */
    public function registerShader (key :String, shader :Shader)
    {
        _shaderManager.addShader(key, shader);
    }

    /** Adds a quad to the batch, using a shader defined within the material. */
    public function prepareDrawMaterial (renderTarget :Stage3DTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, texture :Stage3DTexture, shader :String) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, scissor, _shaderManager.getShader(shader));
    }

    /** Adds a quad to the batch, using the DrawTexture shader. */
    public function prepareDrawTexture (renderTarget :Stage3DTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, texture :Stage3DTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, scissor, _shaderManager.getShader("drawTexture"));
    }

    /** Adds a quad to the batch, using the DrawPattern shader. */
    public function prepareDrawPattern (renderTarget :Stage3DTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, texture :Stage3DTexture) :Int
    {
        if (texture != _lastTexture) {
            flush();
            _lastTexture = texture;
        }
        return prepareQuad(5, renderTarget, blendMode, scissor, _shaderManager.getShader("drawPattern"));
    }

    /** Adds a quad to the batch, using the FillRect shader. */
    public function prepareFillRect (renderTarget :Stage3DTextureRoot,
        blendMode :BlendMode, scissor :Rectangle) :Int
    {
        return prepareQuad(6, renderTarget, blendMode, scissor, _shaderManager.getShader("fillRect"));
    }

    private function prepareQuad (elementsPerVertex :Int, renderTarget :Stage3DTextureRoot,
        blendMode :BlendMode, scissor :Rectangle, shader :Shader) :Int
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
                if (scissor != null) {
                    _scratchScissor.copyFrom(scissor); // Copy by value
                    _lastScissor = _scratchScissor;
                } else {
                    _lastScissor = null;
                }
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
            if (_lastRenderTarget != null) {
                _context3D.setRenderToTexture(_lastRenderTarget.nativeTexture, false, 2);
            } else {
                _context3D.setRenderToBackBuffer();
            }
            Log.warn("Changing render target, clearing it first as required by Stage3D");
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
                case Multiply: _context3D.setBlendFactors(DESTINATION_COLOR, ONE_MINUS_SOURCE_ALPHA);
                case Screen: _context3D.setBlendFactors(ONE, ONE_MINUS_SOURCE_COLOR);
                case Mask: _context3D.setBlendFactors(ZERO, SOURCE_ALPHA);
                case Copy: _context3D.setBlendFactors(ONE, ZERO);
            }
            _currentBlendMode = _lastBlendMode;
        }

        if (_pendingSetScissor) {
            _context3D.setScissorRectangle(_lastScissor);
            _pendingSetScissor = false;
        }

        var vertexBuffer = null;
        var drawPatternShader = cast(_shaderManager.getShader("drawPattern"), DrawPattern);
        var fillRectShader = cast(_shaderManager.getShader("fillRect"), FillRect);


        // TODO(bruno): Optimize with switch/case?
        if (_lastShader == drawPatternShader) {
            var region = _scratchVector3D;
            var texture = _lastTexture;
            var root = texture.root;
            region.z = texture.rootX / root.width; // x
            region.w = texture.rootY / root.height; // y
            region.x = texture.width / root.width; // width
            region.y = texture.height / root.height; // height
            drawPatternShader.texture = root.nativeTexture;
            drawPatternShader.region = region;
            drawPatternShader.rebuildVars();
            vertexBuffer = _vertexBuffer5;

        } else if (_lastShader == fillRectShader) {
            vertexBuffer = _vertexBuffer6;
        } else {
            if (_lastShader != _currentShader) {
                _lastShader.rebuildVars();
                _currentShader = _lastShader;
                vertexBuffer = _vertexBuffer5;
            }

            if (_lastTexture != _currentTexture) {
                bindTexture(_lastTexture.root);
                _currentTexture = _lastTexture;
            }
        }

        // vertexBuffer.uploadFromVector(data, 0, _quads*4);
        vertexBuffer.uploadFromVector(data, 0, _maxQuads*4);
        _lastShader.bind(_context3D, vertexBuffer);
        _context3D.drawTriangles(_quadIndexBuffer, 0, _quads*2);
        _lastShader.unbind(_context3D);

#if flambe_debug_renderer
        trace("Flushed " + _quads + " / " + _maxQuads + " quads");
#end
        _quads = 0;
        _dataOffset = 0;
    }

    private function bindTexture(root :Stage3DTextureRoot)
    {
        var drawTextureShader = cast(_shaderManager.getShader("drawTexture"), DrawTexture);

        if(_lastShader == drawTextureShader)
            drawTextureShader.texture = root.nativeTexture;
        else
        {
            var customShader = cast(_lastShader, ShaderHXSL);
            customShader.bindTexture(root.nativeTexture);
        }
    }

    private function resize (maxQuads :Int)
    {
        flush();
        if (maxQuads > MAX_BATCH_QUADS) {
            return; // That's big enough, return right after the flush
        }

        _maxQuads = maxQuads;
        data = new Vector<Float>(maxQuads*4*MAX_ELEMENTS_PER_VERTEX, true);

        var indices = new Vector<UInt>(6*maxQuads, true);
        for (ii in 0...maxQuads) {
            indices[ii*6 + 0] = ii*4 + 0;
            indices[ii*6 + 1] = ii*4 + 1;
            indices[ii*6 + 2] = ii*4 + 2;
            indices[ii*6 + 3] = ii*4 + 2;
            indices[ii*6 + 4] = ii*4 + 3;
            indices[ii*6 + 5] = ii*4 + 0;
        }
        if (_quadIndexBuffer != null) {
            _quadIndexBuffer.dispose();
        }
        _quadIndexBuffer = _context3D.createIndexBuffer(indices.length);
        _quadIndexBuffer.uploadFromVector(indices, 0, indices.length);

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
    private var _lastRenderTarget :Stage3DTextureRoot;
    private var _lastShader :Shader;
    private var _lastTexture :Stage3DTexture;
    private var _lastScissor :Rectangle;

    // Used to avoid redundant Context3D calls
    private var _currentBlendMode :BlendMode;
    private var _currentRenderTarget :Stage3DTextureRoot;
    private var _currentTexture :Stage3DTexture = null; // ADDED
    private var _currentShader :Shader = null; // ADDED

    // Extra stuff for scissor test tracking
    private var _scratchScissor :Rectangle;
    private var _pendingSetScissor :Bool;

    private var _shaderManager : Stage3DShaderManager;

    private var _quadIndexBuffer :IndexBuffer3D;
    private var _vertexBuffer5 :VertexBuffer3D;
    private var _vertexBuffer6 :VertexBuffer3D;

    private var _quads :Int;
    private var _maxQuads :Int;
    private var _dataOffset :Int;
}
