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
    implements InternalGraphics
{
    public function new (canvas :CanvasElement, alpha :Bool)
    {
        _canvasCtx = (untyped canvas).getContext("2d", {alpha: alpha});
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
        _canvasCtx.transform(m00, m10, m01, m11, m02, m12);
    }

    public function restore ()
    {
        _canvasCtx.restore();
    }

    public function drawTexture (texture :Texture, destX :Float, destY :Float)
    {
        drawSubTexture(texture, destX, destY, 0, 0, texture.width, texture.height);
    }

    public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        if (_firstDraw) {
            _firstDraw = false;
            _canvasCtx.globalCompositeOperation = "copy";
            drawSubTexture(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
            _canvasCtx.globalCompositeOperation = "source-over";
            return;
        }

        var texture :CanvasTexture = cast texture;
        var root = texture.root;
        root.assertNotDisposed();

        _canvasCtx.drawImage(root.image,
            Std.int(texture.rootX+sourceX), Std.int(texture.rootY+sourceY),
            Std.int(sourceW), Std.int(sourceH),
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
        var root = texture.root;
        root.assertNotDisposed();

        _canvasCtx.fillStyle = texture.getPattern();
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

        // Convert color into a hex string in the form of #RRGGBB
        var hex = untyped (0xffffff & color).toString(16);
        while (hex.length < 6) {
            hex = "0"+hex;
        }
        _canvasCtx.fillStyle = "#"+hex;
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
            case Multiply: op = "multiply";
            case Screen: op = "screen";
            case Mask: op = "destination-in";
            case Copy: op = "copy";
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

    public function didRender ()
    {
        // Nothing at all
    }

    public function onResize (width :Int, height :Int)
    {
        // Nothing at all
    }

    private var _canvasCtx :CanvasRenderingContext2D;
    private var _firstDraw :Bool = false;
}
