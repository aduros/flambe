//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;
import flambe.util.Disposable;

/**
 * Represents a collection of fully loaded assets.
 */
interface AssetPack extends Disposable
{
    /**
     * The manifest that was used to load this asset pack.
     */
    var manifest (get, null) :Manifest;

    /**
     * Gets a texture by name from the asset pack. The name must NOT contain a filename extension.
     * Textures are cached, so it's safe to get the same texture multiple times.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function getTexture (name :String, required :Bool = true) :Texture;

    /**
     * Gets a sound by name from the asset pack. The name must NOT contain a filename extension.
     * Sounds are cached, so it's safe to get the same sound multiple times.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function getSound (name :String, required :Bool = true) :Sound;

    /**
     * Gets a file by name from the asset pack, returning its raw content. Files are cached, so it's
     * safe to get the same file multiple times.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function getFile (name :String, required :Bool = true) :File;

    /**
     * Disposes all the assets in this AssetPack. After calling this, any calls to getTexture,
     * getSound, or getFile will assert.
     */
    function dispose () :Void;
}
