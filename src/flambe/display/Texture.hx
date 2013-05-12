//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.math.Rectangle;

import haxe.io.Bytes;

/**
 * A loaded texture image.
 */
interface Texture
{
    /**
     * The width of this texture, in pixels.
     */
    var width (get, null) :Int;

    /**
     * The height of this texture, in pixels.
     */
    var height (get, null) :Int;

    /**
     * <p>The Graphics that draws to this texture.</p>
     *
     * <p>NOTE: In Flash/AIR, this API is currently experimental. Stage3D forces render targets to
     * be cleared before first rendering, so this may cause the texture to be cleared. If you need
     * to support Stage3D, consider keeping a second cache texture and flipping between them.</p>
     */
    var graphics (get, null) :Graphics;

    /**
     * Reads pixels out from the given region. This is potentially a very SLOW operation, avoid
     * overusing it.
     *
     * @returns A byte buffer in RGBA order.
     */
    function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes;

    /**
     * <p>Writes pixels at a given position. sourceW/H is the width and height of the given byte
     * buffer. This is potentially a very SLOW operation, avoid overusing it.</p>
     *
     * <p>NOTE: In Flash/AIR, this API is currently experimental. Stage3D forces render targets to
     * be cleared before first rendering, so this may cause the texture to be cleared. If you need
     * to support Stage3D, consider keeping a second cache texture and flipping between them.</p>
     *
     * @param pixels A byte buffer in RGBA order.
     */
    function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int) :Void;

    /**
     * <p>Determines a rectangular region that fully encloses all pixels of a specified color within
     * the texture.</p>
     *
     * <p>Use mask to specify which values you are interested in (e.g. 0xff000000 = transparency,
     * 0xff = blue, etc.).  Use the color to specify the color to match.  Pixels whose masked color
     * does not match the given color will be discounted from the returned area.</p>
     *
     * <p>Color values are ARGB.</p>
     *
     * @param The mask for extracting values of interest from pixels.
     * @param The color to search for.
     * @param Set this to true to find bounds that do not match the color.
     * @return The bounds of the image matching the color.
     */
    function getColorBounds(mask :Int, color :Int, ?negate :Bool) :Rectangle;
}
