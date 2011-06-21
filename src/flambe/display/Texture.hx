//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.display;

typedef Texture =
#if flash
    flash.display.BitmapData;
#elseif amity
    Dynamic;
#end
