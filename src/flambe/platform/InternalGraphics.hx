//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.Graphics;

interface InternalGraphics extends Graphics
{
    /** Called at the beginning of a frame. */
    function willRender () :Void;

    /** Called at the end of a frame. */
    function didRender () :Void;

    /** Called when the buffer being drawn to was resized. */
    function onResize (width :Int, height :Int) :Void;
}
