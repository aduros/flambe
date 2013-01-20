//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.platform.html.WebGLTypes;

class WebGLGraphics
    implements Graphics
{
    public function new (gl :RenderingContext)
    {
        _gl = gl;
    }

    public function save ()
    {
    }

    public function translate (x :Float, y :Float)
    {
    }

    public function scale (x :Float, y :Float)
    {
    }

    public function rotate (rotation :Float)
    {
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
    }

    public function restore ()
    {
    }

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
    }

    public function multiplyAlpha (factor :Float)
    {
    }

    public function setAlpha (alpha :Float)
    {
    }

    public function setBlendMode (blendMode :BlendMode)
    {
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
    }

    private var _gl :RenderingContext;
}
