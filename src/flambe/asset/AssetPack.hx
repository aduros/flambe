//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;

/**
 * Represents a collection of fully loaded assets.
 */
interface AssetPack
{
    /**
     * The manifest that was used to load this asset pack.
     */
    var manifest (getManifest, null) :Manifest;

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
     * Gets a file by name from the asset pack, returning its contents as a string. Files are
     * cached, so it's safe to get the same file multiple times.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function getFile (name :String, required :Bool = true) :String;
}
