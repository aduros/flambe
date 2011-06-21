//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Texture;

interface DrawingContext
{
    function save () :Void;
    function translate (x :Float, y :Float) :Void;
    function scale (x :Float, y :Float) :Void;
    function rotate (rotation :Float) :Void;
    function multiplyAlpha (factor :Float) :Void;
    function restore () :Void;

    function drawImage (texture :Texture, destX :Float, destY :Float) :Void;
    function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float) :Void;
    function drawPattern (texture :Texture, destX :Float, destY :Float, width :Float, height :Float) :Void;
    function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float) :Void;
}
