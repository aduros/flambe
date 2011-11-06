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
        _assetsRemaining = entries.length;
        _assets = new Hash();

        _bytesLoaded = new Hash();

        if (_assetsRemaining == 0) {
            // There's nothing to load, just send them an empty pack
            handleSuccess();

        } else {
            var bytesTotal = 0;
            for (entry in entries) {
                bytesTotal += entry.bytes;
                loadEntry(entry);
            }
            promise.total = bytesTotal;
        }
    }

    private function loadEntry (entry :AssetEntry)
    {
        // See subclasses
    }

    private function handleLoad (entry :AssetEntry, asset :Dynamic)
    {
        _assets.set(entry.name, asset);

        _assetsRemaining -= 1;
        if (_assetsRemaining <= 0) {
            handleSuccess();
        }
    }

    private function handleProgress (entry :AssetEntry, bytesLoaded :Int)
    {
        _bytesLoaded.set(entry.name, bytesLoaded);

        var bytesTotal = 0;
        for (bytes in _bytesLoaded) {
            bytesTotal += bytes;
        }
        promise.progress = bytesTotal;
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

    // How many assets are still loading
    private var _assetsRemaining :Int;

    // How many bytes of each asset have been loaded
    private var _bytesLoaded :Hash<Int>;
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
