//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * Blend mode used to composite a sprite.
 *
 * See [Wikipedia](https://en.wikipedia.org/wiki/Blend_modes) for more info.
 */
enum BlendMode
{
    /**
     * Blends the source color on top of the destination, respecting transparency.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Normal.png">
     */
    Normal;

    /**
     * Adds the source and destination colors, lightening the final image.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Add.png">
     */
    Add;

    /**
     * Multiplies the source and destination colors, darkening the final image.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Multiply.png">
     */
    Multiply;

    /**
     * Inverts and multiplies the source and destination colors, lightening the final image.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Screen.png">
     */
    Screen;

    /**
     * Masks the overlapping area by applying the source alpha to the destination image.
     *
     * __WARNING__: In HTML5 canvas, this blend mode is unbounded. It will clear the entire
     * destination image, not just the bounds within the source image.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Mask.png">
     */
    Mask;

    /**
     * Ignores the destination color, and copies the source without handling transparency.
     *
     * __WARNING__: In HTML5 canvas, this blend mode is unbounded. It will clear the entire
     * destination image, not just the bounds within the source image.
     *
     * <img src="https://aduros.com/flambe/images/BlendMode-Copy.png">
     */
    Copy;
}
