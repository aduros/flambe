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
     * The Graphics that draws to this texture.
     *
     * _NOTE_: In Flash/AIR, this API is currently experimental. Stage3D forces render targets to be
     * cleared before first rendering, so this may cause the texture to be cleared. If you need to
     * support Stage3D, consider keeping a second cache texture and flipping between them.
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
     * Writes pixels at a given position. sourceW/H is the width and height of the given byte
     * buffer. This is potentially a very SLOW operation, avoid overusing it.
     *
     * _NOTE_: In Flash/AIR, this API is currently experimental. Stage3D forces render targets to be
     * cleared before first rendering, so this may cause the texture to be cleared. If you need to
     * support Stage3D, consider keeping a second cache texture and flipping between them.
     *
     * @param pixels A byte buffer in RGBA order.
     */
    function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int) :Void;

    /**
     * Creates a SubTexture that displays a region of this texture.
     *
     * The returned sub-texture is only a "view", so any changes to the parent texture will affect
     * its regions. Repeatedly nested sub-textures are allowed.
     *
     * _NOTE_: The `graphics` instance of the sub-texture is the same as its parent. This means you
     * may need to `translate()` first when working with sub-textures, and take care not to conflict
     * with other textures' `graphics`.
     *
     * @param x The X offset of the region.
     * @param y The Y offset of the region.
     * @param width The width of the region.
     * @param height The height of the region.
     */
    function subTexture (x :Int, y :Int, width :Int, height :Int) :SubTexture;

    /**
     * Splits this texture into multiple tiles using `subTexture()`.
     *
     * @param tilesWide The width, in number of tiles.
     * @param tilesHigh The height, in number of tiles.
     */
    function split (tilesWide :Int, tilesHigh :Int = 1) :Array<SubTexture>;
}
