//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;

import flambe.display.BlendMode;
import flambe.display.DrawingContext;
import flambe.display.Texture;

class Stage3DDrawingContext
    implements DrawingContext
{
    public function new (context3D :Context3D)
    {
        _context3D = context3D;
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

    public function restore ()
    {
    }

    public function drawImage (texture :Texture, destX :Float, destY :Float)
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

    public function setBlendMode (blendMode :BlendMode)
    {
    }

    private var _context3D :Context3D;
}
