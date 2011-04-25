package flambe.platform;

import flambe.display.Texture;

interface DrawingContext
{
    function save () :Void;
    function translate (x :Float, y :Float) :Void;
    function scale (x :Float, y :Float) :Void;
    function rotate (rotation :Float) :Void;
    function restore () :Void;
    function drawImage (texture :Texture, x :Int, y :Int) :Void;
    function drawPattern (texture :Texture, x :Int, y :Int, width :Float, height :Float) :Void;
    function multiplyAlpha (alpha :Float) :Void;
}
