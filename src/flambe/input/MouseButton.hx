//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * All the possible mouse buttons that can be handled. Use Unknown to handle any platform-specific
 * buttons not supported here.
 */
enum MouseButton
{
    Left; Middle; Right;

    /**
     * Used if the environment sends an unknown button.
     */
    Unknown (buttonCode :Int);
}
