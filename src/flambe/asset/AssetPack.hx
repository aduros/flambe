package flambe.asset;

import flambe.display.Texture;

interface AssetPack
{
    public function createTexture (file :String) :Texture;

    //public function createXml (file :String) :Xml;
    //public function createBytes (file :String) :haxe.io.Bytes;
}
