package flambe.platform.amity;

import flambe.asset.AssetPack;
import flambe.display.Texture;

class AmityAssetPack
    implements AssetPack
{
    public function new (packName :String)
    {
        _packName = packName;
    }

    public function createTexture (file :String) :Texture
    {
        return (untyped __amity).createTexture(_packName + "/" + file);
    }

    private var _packName :String;
}
