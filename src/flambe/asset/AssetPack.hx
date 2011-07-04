//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.asset;

import flambe.display.Texture;

interface AssetPack
{
    public function createTexture (file :String) :Texture;

    public function loadFile (file :String) :String;

    //public function createXml (file :String) :Xml;
    //public function createBytes (file :String) :haxe.io.Bytes;
}
