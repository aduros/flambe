//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.subsystem.RendererSystem;

interface InternalRenderer<NativeImage> extends RendererSystem<NativeImage>
{
    public var graphics :InternalGraphics;

    /**
     * The compressed texture formats supported by this renderer.
     */
    function getCompressedTextureFormats () :Array<AssetFormat>;

    function createCompressedTexture (format :AssetFormat, data :Bytes) :Texture;

    /**
     * Notifies the renderer that things are about to be drawn.
     */
    function willRender () :Void;

    /**
     * Notifies the renderer that drawing the frame is complete.
     */
    function didRender () :Void;
}
