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

    public function drawTexture (texture :Texture, x :Int, y :Int)
    {
        canvas().drawTexture(texture, x, y);
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
