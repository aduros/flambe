//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.display.Texture;

interface AssetPack
{
    public function loadTexture (file :String) :Texture;

    public function loadFile (file :String) :String;
}
