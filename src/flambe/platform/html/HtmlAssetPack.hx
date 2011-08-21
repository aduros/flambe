//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.asset.AssetPack;
import flambe.display.Texture;

class HtmlAssetPack
    implements AssetPack
{
    public function new (contents :Hash<Dynamic>)
    {
        _contents = contents;
    }

    public function loadTexture (file :String) :Texture
    {
        return cast _contents.get(file);
    }

    public function loadFile (file :String) :String
    {
        return cast _contents.get(file);
    }

    private var _contents :Hash<Dynamic>;
}
