//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.asset.AssetPack;
import flambe.display.Texture;
import flambe.util.Promise;

class BasicAssetPackLoader
{
    public var promise (default, null) :Promise<AssetPack>;

    public function new (manifest :Manifest)
    {
        promise = new Promise();
        _manifest = manifest;

        var entries = manifest.getEntries();
        _assetsLoaded = 0;
        _assetsTotal = entries.length;
        _assets = new Hash();

        if (_assetsTotal == 0) {
            // There's nothing to load, just send them an empty pack
            handleSuccess();

        } else {
            for (entry in entries) {
                loadEntry(entry);
            }
        }
    }

    private function loadEntry (entry :AssetEntry)
    {
        // See subclasses
    }

    private function handleLoad (entry :AssetEntry, asset :Dynamic)
    {
        trace("Loaded " + entry.name);
        _assets.set(entry.name, asset);

        _assetsLoaded += 1;
        if (_assetsLoaded >= _assetsTotal) {
            handleSuccess();
        }
    }

    private function handleSuccess ()
    {
        promise.result = new BasicAssetPack(_manifest, _assets);
    }

    private function handleError (message :String)
    {
        promise.error.emit(message);
    }

    private var _manifest :Manifest;
    private var _assets :Hash<Dynamic>;

    private var _assetsLoaded :Int;
    private var _assetsTotal :Int;
}

// A simple AssetPack backed by a Hash
private class BasicAssetPack
    implements AssetPack
{
    public var manifest (getManifest, null) :Manifest;

    public function new (manifest :Manifest, contents :Hash<Dynamic>)
    {
        _manifest = manifest;
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

    public function getManifest () :Manifest
    {
        return _manifest;
    }

    private var _manifest :Manifest;
    private var _contents :Hash<Dynamic>;
}
