//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.BlendMode;
import flambe.display.Texture;

class OverdrawGraphics
    implements InternalGraphics
{
    public function new (impl :InternalGraphics)
    {
        _impl = impl;
    }

    public function save ()
    {
        _impl.save();
    }

    public function translate (x :Float, y :Float)
    {
        _impl.translate(x, y);
    }

    public function scale (x :Float, y :Float)
    {
        _impl.scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        _impl.rotate(rotation);
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        _impl.transform(m00, m10, m01, m11, m02, m12);
    }

    public function multiplyAlpha (factor :Float)
    {
        // Ignore
    }

    public function setAlpha (alpha :Float)
    {
        // Ignore
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        // Ignore
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        _impl.applyScissor(x, y, width, height);
    }

    public function restore ()
    {
        _impl.restore();
    }

    public function drawTexture (texture :Texture, destX :Float, destY :Float)
    {
        drawRegion(destX, destY, texture.width, texture.height);
    }

    public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        drawRegion(destX, destY, sourceW, sourceH);
    }

    public function drawPattern (texture :Texture, destX :Float, destY :Float, width :Float, height :Float)
    {
        drawRegion(destX, destY, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        drawRegion(x, y, width, height);
    }

    public function willRender ()
    {
        _impl.willRender();
        _impl.save();
        _impl.setBlendMode(Add);
    }

    public function didRender ()
    {
        _impl.restore();
        _impl.didRender();
    }

    public function onResize (width :Int, height :Int)
    {
        _impl.onResize(width, height);
    }

    /** Draws an overdraw region rectangle. */
    private function drawRegion (x :Float, y :Float, width :Float, height :Float)
    {
        _impl.fillRect(0x101008, x, y, width, height);
    }

    private var _impl :InternalGraphics;
}
