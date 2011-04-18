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

    public function createTexture (file :String) :Texture
    {
        var texture = _textureCache.get(file);
        if (texture == null) {
            texture = _source.createTexture(file);
            _textureCache.set(file, texture);
        }
        return texture;
    }

    private var _source :AssetPack;
    private var _textureCache :Hash<Texture>;
}
