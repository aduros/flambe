//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import haxe.io.Bytes;

import flambe.asset.Asset;

/**
 * A loaded texture image.
 */
interface Texture extends Asset
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
}
