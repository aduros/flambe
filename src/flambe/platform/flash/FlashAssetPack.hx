//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.utils.ByteArray;

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

    public function loadTexture (file :String) :Texture
    {
        return Type.createInstance(getDefinition(file), []);
    }

    public function loadFile (file :String) :String
    {
        var byteArray :ByteArray = Type.createInstance(getDefinition(file), []);
        return byteArray.readUTFBytes(byteArray.length);
    }

    private function getDefinition<A> (file :String) :Class<A>
    {
        return _loaderInfo.applicationDomain.getDefinition(file.replace(".", "$"));
    }

    private var _loaderInfo :LoaderInfo;
}
