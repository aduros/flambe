//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.display.Texture;
import flambe.util.Value;

/**
 * Functions related to the device's renderer.
 */
interface RendererSystem<NativeImage>
{
    /**
     * The type of this renderer.
     */
    var type (get, null) :RendererType;

    /**
     * The maximum width and height of a Texture on this renderer, in pixels. Guaranteed to be at
     * least 1024.
     */
    var maxTextureSize (get, null) :Int;

    /**
     * Whether the renderer currently has a GPU context. In some renderers (Stage3D and WebGL) the
     * GPU and all its resources may be destroyed at any time by the system. On renderers that don't
     * need to worry about reclaiming GPU resources (Canvas) this is always true.
     *
     * When this becomes false, all Textures and Graphics objects are destroyed and become invalid.
     * When it returns to true, apps should reload its textures.
     */
    var hasGPU (get, null) :Value<Bool>;

    /**
     * Creates a new blank texture, initialized to transparent black.
     *
     * @param width The width of the texture, in pixels.
     * @param height The height of the texture, in pixels.
     *
     * @returns The new texture, or null if the GPU context is currently unavailable.
     */
    function createTexture (width :Int, height :Int) :Texture;

    /**
     * Creates a new texture from native image data. Normally you should use
     * `System.loadAssetPack()` to load textures, but this can be useful for working with external
     * code that deals with native images.
     *
     * @param image The platform-specific image data. In Flash, this is a BitmapData. In HTML, this
     * is an ImageElement, CanvasElement, or VideoElement.
     *
     * @returns The new texture, or null if the GPU context is currently unavailable.
     */
    function createTextureFromImage (image :NativeImage) :Texture;

    // function createBuffer (size :Int) :Buffer;
    // function createShader (glsl :String) :Shader;
}

enum RendererType
{
    Stage3D;
    WebGL;
    Canvas;
}
