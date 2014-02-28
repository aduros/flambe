//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import haxe.io.Bytes;

import flambe.display.Graphics;
import flambe.display.Texture;

/**
 * The "root" of a texture atlas. An internal abstraction that makes implementing subTexture() easier
 * across platforms.
 */
interface TextureRoot
{
    var width (default, null) :Int;
    var height (default, null) :Int;

    function createTexture (width :Int, height :Int) :Texture; // BasicTexture<R>

    function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes;
    function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int) :Void;

    function getGraphics () :Graphics;
}
