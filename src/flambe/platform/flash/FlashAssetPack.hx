package flambe.platform.flash;

import flash.display.Loader;
import flash.display.LoaderInfo;

import flambe.asset.AssetPack;
import flambe.display.Texture;

using StringTools;

class FlashAssetPack
    implements AssetPack
{
    public function new (loaderInfo :LoaderInfo)
    {
        _loaderInfo = loaderInfo;
    }

    public function createTexture (file :String) :Texture
    {
         return Type.createInstance(
         _loaderInfo.applicationDomain.getDefinition(
            file.replace(".", "$")), []);
    }

    private var _loaderInfo :LoaderInfo;
}
