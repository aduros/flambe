//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;

// TODO(bruno): Remove pixel snapping once most browsers get canvas acceleration.
class CanvasGraphics
    implements Graphics
{
    public function new (canvas :CanvasElement)
    {
        _canvasCtx = canvas.getContext2d();
    }

    public function save ()
    {
        _canvasCtx.save();
    }

    public function translate (x :Float, y :Float)
    {
        _canvasCtx.translate(Std.int(x), Std.int(y));
    }

    public function scale (x :Float, y :Float)
    {
        _canvasCtx.scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        _canvasCtx.rotate(FMath.toRadians(rotation));
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        _canvasCtx.transform(m00, m10, m01, m11, Std.int(m02), Std.int(m12));
    }

    public function restore ()
    {
        _canvasCtx.restore();
    }

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
        if (_firstDraw) {
            _firstDraw = false;
            _canvasCtx.globalCompositeOperation = "copy";
            drawImage(texture, x, y);
            _canvasCtx.globalCompositeOperation = "source-over";
            return;
        }

        var texture :CanvasTexture = cast texture;
        _canvasCtx.drawImage(texture.image, Std.int(x), Std.int(y));
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        if (_firstDraw) {
            _firstDraw = false;
            _canvasCtx.globalCompositeOperation = "copy";
            drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
            _canvasCtx.globalCompositeOperation = "source-over";
            return;
        }

        var texture :CanvasTexture = cast texture;
        _canvasCtx.drawImage(texture.image,
            Std.int(sourceX), Std.int(sourceY), Std.int(sourceW), Std.int(sourceH),
            Std.int(destX), Std.int(destY), Std.int(sourceW), Std.int(sourceH));
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        if (_firstDraw) {
            _firstDraw = false;
            _canvasCtx.globalCompositeOperation = "copy";
            drawPattern(texture, x, y, width, height);
            _canvasCtx.globalCompositeOperation = "source-over";
            return;
        }

        var texture :CanvasTexture = cast texture;
        if (texture.pattern == null) {
            texture.pattern = _canvasCtx.createPattern(texture.image, "repeat");
        }
        _canvasCtx.fillStyle = texture.pattern;
        _canvasCtx.fillRect(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        if (_firstDraw) {
            _firstDraw = false;
            _canvasCtx.globalCompositeOperation = "copy";
            fillRect(color, x, y, width, height);
            _canvasCtx.globalCompositeOperation = "source-over";
            return;
        }

        // Use slice() here rather than Haxe's substr monkey patch
        _canvasCtx.fillStyle = untyped "#" + ("00000" + color.toString(16)).slice(-6);
        _canvasCtx.fillRect(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
    }

    public function multiplyAlpha (factor :Float)
    {
        _canvasCtx.globalAlpha *= factor;
    }

    public function setAlpha (alpha :Float)
    {
        _canvasCtx.globalAlpha = alpha;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        var op;
        switch (blendMode) {
            case Normal: op = "source-over";
            case Add: op = "lighter";
            case CopyExperimental:
                // No, we can't use the canvas "copy" globalCompositeOperation, as it's unbounded.
                // ie. Drawing a small square with copy will erase the ENTIRE rest of the stage.
                // Maybe this could be properly implemented with a mask, but that will probably kill
                // performance, which is sort of half the point of using copy.
                op = "source-over";
        };
        _canvasCtx.globalCompositeOperation = op;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        _canvasCtx.beginPath();
        _canvasCtx.rect(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
        _canvasCtx.clip();
    }

    public function willRender ()
    {
        // Disable blending for the first draw call. This squeezes a bit of performance out of games
        // that have a single large background sprite, especially on older devices
        _firstDraw = true;
    }

    private var _canvasCtx :CanvasRenderingContext2D;
    private var _firstDraw :Bool = false;
}
