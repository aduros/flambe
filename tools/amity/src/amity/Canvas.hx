//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package amity;

@:native("__amity.canvas")
extern class Canvas
{
    public static var WIDTH (default, null) :Int;
    public static var HEIGHT (default, null) :Int;

    public static function save () :Void;
    public static function translate (x :Float, y :Float) :Void;
    public static function scale (x :Float, y :Float) :Void;
    public static function rotate (rotation :Float) :Void;
    public static function multiplyAlpha (factor :Float) :Void;
    public static function restore () :Void;

    public static function drawImage (texture :Texture, destX :Float, destY :Float,
        ?sourceX :Float, ?sourceY :Float, ?sourceW :Float, ?sourceH :Float) :Void;

    public static function drawPattern (texture :Texture, x :Float, y :Float,
        width :Float, height :Float) :Void;

    public static function fillRect (color :Int, x :Float, y :Float,
        width :Float, height :Float) :Void;
}
