//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;

interface AssetPack
{
    var manifest (getManifest, null) :Manifest;

    function loadTexture (name :String) :Texture;
    function loadSound (name :String) :Sound;
    function loadFile (name :String) :String;
}
