//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

// TODO: Make this a class that nicely hides the platform specific object
typedef Texture =
#if flash
    flash.display.BitmapData;
#elseif js
    Dynamic;
#elseif amity
    Dynamic;
#end
