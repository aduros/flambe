package flambe.display;

typedef Texture =
#if flash
    flash.display.BitmapData;
#elseif amity
    Dynamic;
#end
