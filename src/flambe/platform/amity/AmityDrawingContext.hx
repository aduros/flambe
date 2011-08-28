//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.amity;

import amity.Canvas;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class AmityDrawingContext
    implements DrawingContext
{
    public function new ()
    {
    }

    public function save ()
    {
        Canvas.save();
    }

    public function translate (x :Float, y :Float)
    {
        Canvas.translate(x, y);
    }

    public function scale (x :Float, y :Float)
    {
        Canvas.scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        Canvas.rotate(rotation);
    }

    public function restore ()
    {
        Canvas.restore();
    }

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
        Canvas.drawImage(texture, x, y);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        Canvas.drawImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        Canvas.drawPattern(texture, x, y, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        Canvas.fillRect(color, x, y, width, height);
    }

    public function multiplyAlpha (factor :Float)
    {
        Canvas.multiplyAlpha(factor);
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        // Unimplemented
    }
}
