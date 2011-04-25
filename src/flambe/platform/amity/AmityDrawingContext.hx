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

    public function drawPattern (texture :Texture, x :Int, y :Int, width :Float, height :Float)
    {
        canvas().drawPattern(texture, x, y, width, height);
    }

    public function multiplyAlpha (alpha :Float)
    {
        canvas().alpha *= alpha;
    }

    inline public static function canvas () :Dynamic
    {
    	return (untyped __amity).canvas;
    }
}
