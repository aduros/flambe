//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;

interface AssetPack
{
    public var manifest (getManifest, null) :Manifest;

    public function loadTexture (name :String) :Texture;
    public function loadSound (name :String) :Sound;
    public function loadFile (name :String) :String;

    public function getManifest () :Manifest;
}
