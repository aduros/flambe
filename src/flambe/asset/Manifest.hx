//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import haxe.rtti.Meta;

import flambe.asset.AssetEntry;
import flambe.platform.ManifestBuilder;

using flambe.util.Strings;
using StringTools;

class Manifest
{
    public function new ()
    {
        _entries = [];
    }

    // Get a manifest of a pack in the asset directory at build-time
    public static function build (packName :String) :Manifest
    {
        return _buildManifest.get(packName);
    }

    /**
     * Try to find a pack suffixed with the closest available variant of the locale. For example,
     * buildLocalized("foo", "pt-BR") will first try to load foo_pt-BR, then foo_pt, then just foo.
     */
    public static function buildLocalized (packName :String, locale :String = null) :Manifest
    {
        if (locale == null) {
            locale = System.locale;
        }

        if (locale != null) {
            var parts = locale.split("-");
            while (parts.length > 0) {
                var manifest = build(packName + "_" + parts.join("-"));
                if (manifest != null) {
                    return manifest;
                }
                parts.pop();
            }
        }
        return build(packName);
    }

    public static function exists (packName :String) :Bool
    {
        return _buildManifest.exists(packName);
    }

    public function add (name :String, url :String, bytes :Int = 0, ?type :AssetType) :AssetEntry
    {
        if (type == null) {
            type = inferType(url);
        }

        var entry = new AssetEntry(name, url, type, bytes);
        _entries.push(entry);
        return entry;
    }

    public function getEntries () :Array<AssetEntry>
    {
        return _entries.copy();
    }

    private static function inferType (url :String) :AssetType
    {
        return switch (url.split("?")[0].getFileExtension().toLowerCase()) {
            case "png", "jpg", "gif": Image;
            case "ogg", "m4a", "mp3", "wav": Audio;
            default: Data;
        }
    }

    private static function createBuildManifests ()
    {
        var macroData = new Hash<Array<Dynamic>>();
        ManifestBuilder.populate(macroData);

        // The path to our asset packs
        var sameOriginBase = "assets/";
        var crossOriginBase = sameOriginBase;

        var meta = Meta.getType(Manifest);
        if (meta.assetBase != null) {
            crossOriginBase = meta.assetBase[0];
            if (crossOriginBase.fastCodeAt(crossOriginBase.length - 1) != "/".code) {
                // Ensure it ends with a trailing slash
                crossOriginBase += "/";
            }
            if (supportsCrossOrigin()) {
                // We can load ALL asset types from this URL
                sameOriginBase = crossOriginBase;
            }
        }

        var manifests = new Hash();
        for (packName in macroData.keys()) {
            var manifest = new Manifest();
            for (asset in macroData.get(packName)) {
                var name = asset.name;
                var path = packName + "/" + name + "?v=" + asset.md5;

                var type = inferType(name);
                if (type == Audio) {
                    // If this an asset that not all platforms may support, trim the extension from
                    // the name. We'll only load one of the assets if this creates a name collision.
                    name = name.substr(0, name.lastIndexOf("."));
                }

                var base = crossOriginBase;
#if html
                if (type == Data) {
                    // Without CORS, readable data must be loaded from the same origin
                    // TODO(bruno): If Flambe ever gets an API to read pixels out of a texture,
                    // sameOriginBase must be used for images too.
                    base = sameOriginBase;
                }
#end

                manifest.add(name, base + path, asset.bytes, type);
            }
            manifests.set(packName, manifest);
        }
        return manifests;
    }

    /**
     * Returns true if the environment fully supports loading assets on another domain.
     */
    private static function supportsCrossOrigin () :Bool
    {
#if html
        // CORS in the stock Android browser is buggy. If your game is contained in an iframe, XHR
        // will work the first time. If the response had an Expires header, on subsequent page loads
        // instead of retrieving it from the cache, it will fail with error code 0.
        // http://stackoverflow.com/questions/6090816/android-cors-requests-work-only-once
        var blacklist = ~/\b(Android)\b/;
        if (blacklist.match(js.Lib.window.navigator.userAgent)) {
            return false;
        }

        var xhr :Dynamic = new js.XMLHttpRequest();
        return (xhr.withCredentials != null);
#else
        // Assumes you have a valid crossdomain.xml
        return true;
#end
    }

    private static var _buildManifest :Hash<Manifest> = createBuildManifests();

    private var _entries :Array<AssetEntry>;
}
