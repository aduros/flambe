//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetEntry;
import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.sound.Sound;
import flambe.util.Assert;
import flambe.util.Promise;

using Lambda;
using flambe.util.Arrays;
using flambe.util.Strings;

class BasicAssetPackLoader
{
    public var promise (default, null) :Promise<AssetPack>;
    public var manifest (default, null) :Manifest;

    public function new (platform :Platform, manifest :Manifest)
    {
        this.manifest = manifest;
        _platform = platform;
        promise = new Promise();
        _bytesLoaded = new Map();
        _pack = new BasicAssetPack(manifest, this);

        var entries = manifest.array();
        if (entries.length == 0) {
            // There's nothing to load, just send them an empty pack
            handleSuccess();

        } else {
            var groups = new Map<String,Array<AssetEntry>>();

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
                pickBestEntry(group, function (bestEntry :AssetEntry) {
                    if (bestEntry != null) {
                        var url = manifest.getFullURL(bestEntry);
                        try {
                            loadEntry(url, bestEntry);
                        } catch (error :Dynamic) {
                            handleError(bestEntry, "Unexpected error: " + error);
                        }
                        promise.total += bestEntry.bytes;

                    } else {
                        var badEntry = group[0];
                        if (isAudio(badEntry.format)) {
                            // Deal with missing audio files and bad browser support
                            Log.warn("Could not find a supported audio format to load", ["name", badEntry.name]);
                            handleLoad(badEntry, DummySound.getInstance());
                        } else {
                            handleError(badEntry, "Could not find a supported format to load");
                        }
                    }
                });
            }
        }

#if debug
        var catapult = _platform.getCatapultClient();
        if (catapult != null) {
            catapult.add(this);
        }
#end
    }

    /** Reload any asset that matches this URL (ignoring the ?v= query param). */
    public function reload (url :String)
    {
        // Find the AssetEntry that matches this url
        var baseUrl = removeUrlParams(url);
        var foundEntry = null;
        for (entry in manifest) {
            if (baseUrl == removeUrlParams(entry.url)) {
                foundEntry = entry;
                break;
            }
        }

        // If the entry was found in this manifest, and is a supported format
        if (foundEntry != null) {
            getAssetFormats(function (formats :Array<AssetFormat>) {
                if (formats.indexOf(foundEntry.format) >= 0) {
                    // Dummy up a new AssetEntry based on the previous one, and reload it
                    var entry = new AssetEntry(foundEntry.name, url, foundEntry.format, 0);
                    loadEntry(manifest.getFullURL(entry), entry);
                }
            });
        }
    }

    /** Called when this loader's AssetPack is disposed. */
    public function onDisposed ()
    {
#if debug
        var catapult = _platform.getCatapultClient();
        if (catapult != null) {
            catapult.remove(this);
        }
#end
    }

    private static function removeUrlParams (url :String) :String
    {
        var query = url.indexOf("?");
        return (query > 0) ? url.substr(0, query) : url;
    }

    /**
     * Out of a list of asset entries with the same name, select the one best supported by this
     * environment, or null if none of them are supported.
     */
    private function pickBestEntry (entries :Array<AssetEntry>, fn :AssetEntry -> Void)
    {
        var onFormatsAvailable = function (formats :Array<AssetFormat>) {
            for (format in formats) {
                for (entry in entries) {
                    if (entry.format == format) {
                        fn(entry);
                        return;
                    }
                }
            }
            fn(null); // This asset is not supported, we're boned
        };

        getAssetFormats(onFormatsAvailable);
    }

    private function loadEntry (url :String, entry :AssetEntry)
    {
        Assert.fail(); // See subclasses
    }

    /** Gets the list of asset formats the environment supports, ordered by preference. */
    private function getAssetFormats (fn :Array<AssetFormat> -> Void)
    {
        Assert.fail(); // See subclasses
    }

    private function handleLoad<A/*:BasicAsset<A>*/> (entry :AssetEntry, asset :A)
    {
        if (_pack.disposed) {
            return; // Pack was disposed earlier, forget about it
        }

        // Ensure this asset has been fully progressed
        handleProgress(entry, entry.bytes);

        var map :Map<String,Dynamic>;
        switch (entry.format) {
        case WEBP, JXR, PNG, JPG, GIF, DDS, PVR, PKM:
            map = _pack.textures;
        case MP3, M4A, OPUS, OGG, WAV:
            map = _pack.sounds;
        case Data:
            map = _pack.files;
        }

#if debug // Allow some methods to get stripped in release builds, which don't allow reloading
        var oldAsset :BasicAsset<A> = cast map.get(entry.name);
        if (oldAsset != null) {
            Log.info("Reloaded asset", ["url", entry.url]);
            oldAsset.reload(asset);

        } else {
#end
            map.set(entry.name, asset);
            _assetsRemaining -= 1;
            if (_assetsRemaining == 0) {
                handleSuccess();
            }
#if debug
        }
#end
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
        promise.result = _pack;
    }

    private function handleError (entry :AssetEntry, message :String)
    {
        Log.warn("Error loading asset pack", ["error", message, "url", entry.url]);
        promise.error.emit(message.withFields(["url", entry.url]));
    }

    private function handleTextureError (entry :AssetEntry)
    {
        handleError(entry, "Failed to create texture. Is the GPU context unavailable?");
    }

    private static function isAudio (format :AssetFormat) :Bool
    {
        switch (format) {
            case MP3, M4A, OPUS, OGG, WAV: return true;
            default: return false;
        }
    }

    private var _platform :Platform;

    // How many assets are still loading
    private var _assetsRemaining :Int;

    // How many bytes of each asset have been loaded
    private var _bytesLoaded :Map<String,Int>;

    private var _pack :BasicAssetPack;
}

// A simple AssetPack backed by a Map
private class BasicAssetPack
    implements AssetPack
{
    public var manifest (get, null) :Manifest;
    public var loader (default, null) :BasicAssetPackLoader;

    public var textures :Map<String,Texture>;
    public var sounds :Map<String,Sound>;
    public var files :Map<String,File>;

    public var disposed :Bool = false;

    public function new (manifest :Manifest, loader :BasicAssetPackLoader)
    {
        _manifest = manifest;
        this.loader = loader;

        textures = new Map();
        sounds = new Map();
        files = new Map();
    }

    public function getTexture (name :String, required :Bool = true) :Texture
    {
        assertNotDisposed();
#if debug
        warnOnExtension(name);
#end
        var texture = textures.get(name);
        if (texture == null && required) {
            throw "Missing texture".withFields(["name", name]);
        }
        return texture;
    }

    public function getSound (name :String, required :Bool = true) :Sound
    {
        assertNotDisposed();
#if debug
        warnOnExtension(name);
#end
        var sound = sounds.get(name);
        if (sound == null && required) {
            throw "Missing sound".withFields(["name", name]);
        }
        return sound;
    }

    public function getFile (name :String, required :Bool = true) :File
    {
        assertNotDisposed();

        var file = files.get(name);
        if (file == null && required) {
            throw "Missing file".withFields(["name", name]);
        }
        return file;
    }

    // Dispose all assets contained in this pack
    public function dispose ()
    {
        if (!disposed) {
            disposed = true;

            for (texture in textures) {
                texture.dispose();
            }
            textures = null;

            for (sound in sounds) {
                sound.dispose();
            }
            sounds = null;

            for (file in files) {
                file.dispose();
            }
            files = null;

            loader.onDisposed();
        }
    }

    inline private function get_manifest () :Manifest
    {
        return _manifest;
    }

    inline private function assertNotDisposed ()
    {
        Assert.that(!disposed, "AssetPack cannot be used after being disposed");
    }

    private static function warnOnExtension (path :String)
    {
        var ext = path.getFileExtension();
        if (ext != null && ext.length == 3) {
            Log.warn("Requested asset \"" + path + "\" should not have a file extension," +
                " did you mean \"" + path.removeFileExtension() + "\"?");
        }
    }

    private var _manifest :Manifest;
}
