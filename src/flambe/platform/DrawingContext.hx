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

    function drawImage (texture :Texture, destX :Int, destY :Int) :Void;
    function drawSubImage (texture :Texture, destX :Int, destY :Int,
        sourceX :Int, sourceY :Int, sourceW :Int, sourceH :Int) :Void;
    function drawPattern (texture :Texture, destX :Int, destY :Int, width :Float, height :Float) :Void;
    function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float) :Void;
}
