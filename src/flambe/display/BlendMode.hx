//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * Blend mode used to composite a sprite.
 * https://en.wikipedia.org/wiki/Blend_modes
 */
enum BlendMode {
    /**
     * <p>Blends the source color on top of the destination, respecting transparency.</p>
     * <p><img src="https://aduros.com/flambe/images/BlendMode-Normal.png"></p>
     */
    Normal;

    /**
     * <p>Adds the source and destination colors, lightening the final image.</p>
     * <p><img src="https://aduros.com/flambe/images/BlendMode-Add.png"></p>
     */
    Add;

    /**
     * <p>Masks the overlapping area by applying the source alpha to the destination image.</p>
     *
     * <p>WARNING: In HTML5 canvas, this blend mode is unbounded. It will clear the entire
     * destination image, not just the bounds within the source image.</p>
     *
     * <p><img src="https://aduros.com/flambe/images/BlendMode-Mask.png"></p>
     */
    Mask;

    /**
     * <p>Ignores the destination color, and copies the source without handling transparency.</p>
     *
     * <p>WARNING: In HTML5 canvas, this blend mode is unbounded. It will clear the entire
     * destination image, not just the bounds within the source image.</p>
     *
     * <p><img src="https://aduros.com/flambe/images/BlendMode-Copy.png"></p>
     */
    Copy;
}
