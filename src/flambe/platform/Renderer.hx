//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.display.DrawingContext;
import flambe.display.Texture;

interface Renderer
{
    /**
     * Creates a texture from some data source.
     */
    function createTexture (data :Dynamic) :Texture;

    /**
     * Creates a texture, initialized to transparent black.
     */
    function createEmptyTexture (width :Int, height :Int) :Texture;

    /**
     * Notifies the renderer that things are about to be drawn. Returns the drawing context that
     * should be used, or null if no context is currently available.
     */
    function willRender () :DrawingContext;

    /**
     * Notifies the renderer that drawing the frame is complete.
     */
    function didRender () :Void;
}
