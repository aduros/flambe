//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * Draws to a surface.
 */
interface Graphics
{
    /**
     * Saves the graphics state until the next restore(). The state contains the transformation
     * matrix, alpha, blend mode, and scissor rectangle.
     */
    function save () :Void;

    /** Translates the transformation matrix. */
    function translate (x :Float, y :Float) :Void;

    /** Scales the transformation matrix. */
    function scale (x :Float, y :Float) :Void;

    /** Rotates the transformation matrix by the given angle, in degrees. */
    function rotate (rotation :Float) :Void;

    /** Multiplies the transformation matrix by the given matrix. */
    function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float) :Void;

    /** Multiplies the alpha by the given factor. */
    function multiplyAlpha (factor :Float) :Void;

    /** Sets the alpha to use for drawing. */
    function setAlpha (alpha :Float) :Void;

    /** Sets the blend mode to use for drawing. */
    function setBlendMode (blendMode :BlendMode) :Void;

    /**
     * Sets the scissor rectangle to the intersection of the current scissor rectangle and the given
     * rectangle, in local coordinates.
     */
    function applyScissor (x :Float, y :Float, width :Float, height :Float) :Void;

    /** Restores the graphics state back to the previous save(). */
    function restore () :Void;

    /** Draws a texture at the given point. */
    function drawTexture (texture :Texture, destX :Float, destY :Float) :Void;

    /** Draws a texture sub-region at the given point. */
    function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float) :Void;

    /** Draws a repeating texture to the given region. */
    function drawPattern (texture :Texture, destX :Float, destY :Float, width :Float, height :Float) :Void;

    /** Draws a colored rectangle at the given region. */
    function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float) :Void;
}
