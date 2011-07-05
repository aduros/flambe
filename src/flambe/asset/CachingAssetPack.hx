//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.asset;

import flambe.display.Texture;

/**
 * Decorates AssetPack with caching behavior. A texture will be allocated only on the first request,
 * future requests will return the same cached instance.
 */
class CachingAssetPack
    implements AssetPack
{
    public function new (source :AssetPack)
    {
        _source = source;
        _textureCache = new Hash();
    }

    public function loadTexture (file :String) :Texture
    {
        var texture = _textureCache.get(file);
        if (texture == null) {
            texture = _source.loadTexture(file);
            _textureCache.set(file, texture);
        }
        return texture;
    }

    public function loadFile (file :String) :String
    {
        // TODO: Should this be cached too?
        return _source.loadFile(file);
    }

    private var _source :AssetPack;
    private var _textureCache :Hash<Texture>;
}
