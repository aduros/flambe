package flambe.platform.amity;

import flambe.display.Texture;

class AmityDrawingContext
    implements DrawingContext
{
    public function new ()
    {
    }

    public function save ()
    {
        canvas().save();
    }

    public function translate (x :Float, y :Float)
    {
        canvas().translate(x, y);
    }

    public function scale (x :Float, y :Float)
    {
        canvas().scale(x, y);
    }

    public function rotate (rotation :Float)
    {
        canvas().rotate(rotation);
    }

    public function restore ()
    {
        canvas().restore();
    }

    public function drawImage (texture :Texture, x :Int, y :Int)
    {
        canvas().drawImage(texture, x, y);
    }

    public function drawSubImage (texture :Texture, destX :Int, destY :Int,
        sourceX :Int, sourceY :Int, sourceW :Int, sourceH :Int)
    {
        canvas().drawImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
    }

    public function drawPattern (texture :Texture, x :Int, y :Int, width :Float, height :Float)
    {
        canvas().drawPattern(texture, x, y, width, height);
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        canvas().fillRect(color, x, y, width, height);
    }

    public function multiplyAlpha (factor :Float)
    {
        canvas().multiplyAlpha(factor);
    }

    inline public static function canvas () :Dynamic
    {
    	return (untyped __amity).canvas;
    }
}
