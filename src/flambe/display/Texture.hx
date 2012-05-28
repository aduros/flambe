//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

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
}
