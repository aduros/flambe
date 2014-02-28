//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * A sub-region of a texture atlas, created by `Texture.subTexture`.
 */
interface SubTexture extends Texture
{
    /**
     * The original texture that this sub-texture is a part of.
     */
    var parent (get, null) :Texture;

    /**
     * The X offset into the parent texture, in pixels.
     */
    var x (get, null) :Int;

    /**
     * The Y offset into the parent texture, in pixels.
     */
    var y (get, null) :Int;
}
