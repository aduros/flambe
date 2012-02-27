//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetEntry;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;
import flambe.util.Promise;

using flambe.util.Strings;
using Lambda;

class BasicAssetPackLoader
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public var promise (default, null) :Promise<AssetPack>;

    public function new (manifest :Manifest)
    {
        promise = new Promise();
        _manifest = manifest;
        _assets = new Hash();
        _bytesLoaded = new Hash();

        var entries = manifest.getEntries();
        if (entries.length == 0) {
            // There's nothing to load, just send them an empty pack
            handleSuccess();

        } else {
            var bytesTotal = 0;
            var groups = new Hash<Array<AssetEntry>>();

            // Group assets by name
            for (entry in entries) {
                var group = groups.get(entry.name);
                if (group == null) {
                    group = [];
                    groups.set(entry.name, group);
                }
                group.push(entry);
            }

            // Load the most suitable asset from each group
            _assetsRemaining = groups.count();
            for (group in groups) {
                var bestEntry = (group.length > 1) ? pickBestEntry(group) : group[0];
                var placeholder = createPlaceholder(bestEntry);

                if (placeholder != null) {
                    log.warn("Using an asset placeholder",
                        ["name", bestEntry.name, "type", bestEntry.type]);
                    handleLoad(bestEntry, placeholder);

                } else {
                    bytesTotal += bestEntry.bytes;
                    loadEntry(bestEntry);
                }
            }

            promise.total = bytesTotal;
        }
    }

    /**
     * Out of a list of asset entries with the same name, select the one best suited to this
     * environment.
     */
    private function pickBestEntry (entries :Array<AssetEntry>)
    {
        switch (entries[0].type) {
            case Audio:
                var extensions = getAudioFormats();
                for (extension in extensions) {
                    for (entry in entries) {
                        if (entry.getUrlExtension() == extension) {
                            return entry;
                        }
                    }
                }

            default:
                // Fall through
        }

        // No preference, just use the first one
        return entries[0];
    }

    /**
     * If the asset isn't supported by the environment, return a placeholder instead. If null is
     * returned, the asset is supported and we should go ahead and load it.
     */
    private function createPlaceholder (entry :AssetEntry) :Dynamic
    {
        switch (entry.type) {
            case Audio:
                if (!getAudioFormats().has(entry.getUrlExtension())) {
                    return DummySound.getInstance();
                }
            default:
                // Fall through
        }
        return null;
    }

    private function loadEntry (entry :AssetEntry)
    {
        // See subclasses
    }

    /**
     * Returns a list of audio file extensions the environment supports, ordered by preference.
     */
    private function getAudioFormats () :Array<String>
    {
        // See subclasses
        return [];
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
        log.info("Finished loading asset pack");
        promise.result = new BasicAssetPack(_manifest, _assets);
    }

    private function handleError (message :String)
    {
        log.warn("Error loading asset pack", ["error", message]);
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

    public function loadSound (file :String) :Sound
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
