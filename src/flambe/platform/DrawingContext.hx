package flambe.platform;

import flambe.display.Texture;

interface DrawingContext
{
    function save () :Void;
    function translate (x :Float, y :Float) :Void;
    function scale (x :Float, y :Float) :Void;
    function rotate (rotation :Float) :Void;
    function restore () :Void;
    function drawTexture (texture :Texture, x :Int, y :Int) :Void;
    function multiplyAlpha (alpha :Float) :Void;
}
