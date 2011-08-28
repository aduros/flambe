//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.Texture;
import flambe.math.FMath;

// TODO(bruno): Remove pixel snapping once most browsers get canvas acceleration.
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
        _canvasCtx.translate(FMath.toInt(x), FMath.toInt(y));
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
        var htmlTexture :HtmlTexture = cast texture;
        _canvasCtx.drawImage(htmlTexture.image, x, y);
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        var htmlTexture :HtmlTexture = cast texture;
        _canvasCtx.drawImage(htmlTexture.image, FMath.toInt(sourceX), FMath.toInt(sourceY),
            FMath.toInt(sourceW), FMath.toInt(sourceH),
            FMath.toInt(destX), FMath.toInt(destY), FMath.toInt(sourceW), FMath.toInt(sourceH));
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        var htmlTexture :HtmlTexture = cast texture;

        if (htmlTexture.pattern == null) {
            htmlTexture.pattern = _canvasCtx.createPattern(htmlTexture.image, "repeat");
        }
        _canvasCtx.fillStyle = htmlTexture.pattern;
        _canvasCtx.fillRect(FMath.toInt(x), FMath.toInt(y),
            FMath.toInt(width), FMath.toInt(height));
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        _canvasCtx.fillStyle = "#" + (untyped color).toString(16);
        _canvasCtx.fillRect(FMath.toInt(x), FMath.toInt(y),
            FMath.toInt(width), FMath.toInt(height));
    }

    public function multiplyAlpha (factor :Float)
    {
        _canvasCtx.globalAlpha *= factor;
    }

    private var _canvasCtx :Dynamic;
}
