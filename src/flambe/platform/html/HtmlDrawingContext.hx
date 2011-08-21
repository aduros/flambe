//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.Texture;
import flambe.math.FMath;

class HtmlDrawingContext
    implements DrawingContext
{
    public function new (canvas :Dynamic)
    {
        _canvasCtx = canvas.getContext("2d");
    }

    public function save ()
    {
        _canvasCtx.save();
    }

    public function translate (x :Float, y :Float)
    {
        _canvasCtx.translate(x, y);
    }

    public function scale (x :Float, y :Float)
    {
        _canvasCtx.scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        _canvasCtx.rotate(FMath.toRadians(rotation));
    }

    public function restore ()
    {
        _canvasCtx.restore();
    }

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
        _canvasCtx.drawImage(texture, x, y);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        _canvasCtx.drawImage(texture, sourceX, sourceY, sourceW, sourceH,
            destX, destY, sourceW, sourceH);
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        // TODO(bruno): CanvasPattern support
        _canvasCtx.fillStyle = "#660000";
        _canvasCtx.fillRect(x, y, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        _canvasCtx.fillStyle = "#" + (untyped color).toString(16);
        _canvasCtx.fillRect(x, y, width, height);
    }

    public function multiplyAlpha (factor :Float)
    {
        _canvasCtx.alpha *= factor;
    }

    private var _canvasCtx :Dynamic;
}
