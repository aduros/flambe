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
     * Loads a texture by name from the asset pack.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function loadTexture (name :String, required :Bool = true) :Texture;

    /**
     * Loads a sound by name from the asset pack. The name must NOT contain a filename extension.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function loadSound (name :String, required :Bool = true) :Sound;

    /**
     * Loads a file by name from the asset pack, returning its contents as a string.
     * @param required If true and the asset was not found, an error is thrown.
     */
    function loadFile (name :String, required :Bool = true) :String;
}
