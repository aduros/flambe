//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.Manifest;
import flambe.display.Texture;

interface AssetPack
{
    public var manifest (getManifest, null) :Manifest;

    public function loadTexture (name :String) :Texture;

    public function loadFile (name :String) :String;

    public function getManifest () :Manifest;
}
