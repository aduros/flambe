//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import haxe.io.Bytes;

/**
 * A loaded texture image.
 */
interface Texture
{
    /**
     * The width of this texture, in pixels.
     */
    var width (getWidth, null) :Int;

    /**
     * The height of this texture, in pixels.
     */
    var height (getHeight, null) :Int;

    /**
     * The DrawingContext that draws to this texture.
     */
    var ctx (getContext, null) :DrawingContext;

    function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes;

    function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int) :Void;
}
