//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

#if !debug
#error "The canvas inspector should only be included in debug builds!"
#end

import js.Lib;

import flambe.display.BlendMode;
import flambe.display.DrawingContext;
import flambe.display.Texture;

/**
 * Logs all draw calls during a frame, and shows a nice summary. Very useful for spotting texture
 * swapping, overdraw, and rendering glitches. Press CTRL-I to bring up the inspector.
 */
class InspectorDrawingContext
    implements DrawingContext
{
    public function new (ctx :CanvasDrawingContext)
    {
        _ctx = ctx;
    }

    public function save ()
    {
        logMethod("save");
        _ctx.save();
    }

    public function translate (x :Float, y :Float)
    {
        logMethod("translate", [x, y]);
        _ctx.translate(x, y);
    }

    public function scale (x :Float, y :Float)
    {
        logMethod("scale", [x, y]);
        _ctx.scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        logMethod("rotate", [rotation]);
        _ctx.rotate(rotation);
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        logMethod("transform", [m00, m10, m01, m11, m02, m12]);
        _ctx.transform(m00, m10, m01, m11, m02, m12);
    }

    public function restore ()
    {
        logMethod("restore");
        _ctx.restore();
    }

    public function drawImage (texture :Texture, x :Float, y :Float)
    {
        logMethod("drawImage", texture, [x, y]);
        _ctx.drawImage(texture, x, y);
        snapshot();
    }

    public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        logMethod("drawSubImage", texture, [destX, destY, sourceX, sourceY, sourceW, sourceH]);
        _ctx.drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
        snapshot();
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
        logMethod("drawPattern", texture, [x, y, width, height]);
        _ctx.drawPattern(texture, x, y, width, height);
        snapshot();
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        logMethod("fillRect", [color, x, y, width, height]);
        _ctx.fillRect(color, x, y, width, height);
        snapshot();
    }

    public function multiplyAlpha (factor :Float)
    {
        logMethod("multiplyAlpha", [factor]);
        _ctx.multiplyAlpha(factor);
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        logMethod("setBlendMode", [Type.enumConstructor(blendMode)]);
        _ctx.setBlendMode(blendMode);
    }

    public function show ()
    {
        var document = Lib.window.open("", "flambe-inspector").document;
        document.open();
        document.write("<title>Flambe Inspector</title>");
        document.write("<h3>GPU flushes: ~" + _flushes + "</h3>");
        document.write("<p>Draw calls that cause a texture swap are in red.</p>");
        document.write(_htmlOutput);
        document.close();
    }

    private function linkTexture (texture :Texture)
    {
        var texture :HtmlTexture = cast texture;
    }

    private function logMethod (method :String, ?texture :Texture, ?params :Array<Dynamic>)
    {
        var color = "inherit";
        if (texture != null) {
            if (_lastTexture != texture) {
                _lastTexture = texture;
                ++_flushes;
                color = "red";
            }
        }
        _htmlOutput += "<b style='color:" + color + "'>"+method+"</b>";
        if (texture != null) {
            var texture :HtmlTexture = cast texture;
            _htmlOutput += " <a href='" + texture.image.src + "'>" + texture.image.src + "</a>";
        }
        if (params != null) {
            _htmlOutput += " " + params.join(", ");
        }
        _htmlOutput += "<br>";
    }

    private function snapshot ()
    {
        var MAX_SIZE = 400;
        _htmlOutput += "<img style='max-width:" + MAX_SIZE + "px; max-height:" + MAX_SIZE +
            "px;' src='" + _ctx.toDataURL() + "'><br>";
    }

    private var _ctx :CanvasDrawingContext;

    private var _htmlOutput :String = "";

    private var _lastTexture :Texture;
    private var _flushes :Int = 0;
}
