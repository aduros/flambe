//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * Blend mode used to composite a sprite.
 * https://en.wikipedia.org/wiki/Blend_modes
 */
enum BlendMode {
    /** Blends the source color on top of the destination, respecting transparency. */
    Normal;

    /** Adds the source and destination colors, lightening the final image. */
    Add;

    /**
     * Ignores the destination color, and copies the source without handling transparency. NOTE:
     * Supported only in the Stage3D renderer, everywhere else it's the same as Normal.
     *
     * This is an experimental blend mode and may be modified or removed in the future.
     */
    CopyExperimental;
}
