//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import haxe.rtti.Meta;

import flambe.asset.AssetEntry;
import flambe.platform.ManifestBuilder;
import flambe.util.Assert;

using StringTools;
using flambe.util.Strings;

/**
 * An asset manifest contains all the information needed to load an asset pack. A manifest is
 * usually created with Manifest.build("directory"), but manifests can also be assembled
 * programmatically.
 */
class Manifest
{
    /**
     * A relative path to load this manifest's assets from, or null.
     */
    public var relativeBasePath (get, set) :String;

    /**
     * A URL on another domain to load this manifest's assets from, or null. May be used to load
     * assets from a CDN, in browsers that support cross-domain requests.
     */
    public var externalBasePath (get, set) :String;

    public function new ()
    {
        _entries = [];
    }

    /**
     * Gets the manifest of a pack in the asset directory, that was processed at build-time.
     * @param packName The folder name in your assets/ directory.
     * @param required When true and this pack was not found, throw an error. Otherwise null is
     *   returned.
     */
    public static function build (packName :String, required :Bool = true) :Manifest
    {
        var manifest = _buildManifest.get(packName);
        if (manifest == null) {
            if (required) {
                throw "Missing asset pack".withFields(["name", packName]);
            }
            return null;
        }
        return manifest.clone();
    }

    /**
     * Tries to find a pack suffixed with the closest available variant of the locale. For example,
     * buildLocalized("foo", "pt-BR") will first try to load foo_pt-BR, then foo_pt, then just foo.
     * @param packName The folder name in your assets/ directory.
     * @param locale An RFC 4646 language tag, or null to use the system language.
     * @param required When true and this pack was not found, throw an error. Otherwise null is
     *   returned.
     */
    public static function buildLocalized (
        packName :String, locale :String = null, required :Bool = true) :Manifest
    {
        if (locale == null) {
            locale = System.locale;
        }

        if (locale != null) {
            var parts = locale.split("-");
            while (parts.length > 0) {
                var manifest = build(packName + "_" + parts.join("-"), false);
                if (manifest != null) {
                    return manifest;
                }
                parts.pop();
            }
        }
        return build(packName, required);
    }

    /**
     * Returns true if the given named pack was included in the asset directory at build-time.
     */
    public static function exists (packName :String) :Bool
    {
        return _buildManifest.exists(packName);
    }

    /**
     * Adds an asset entry to this manifest.
     * @param name The name of the asset.
     * @param url The URL this asset will be downloaded from.
     * @param bytes The size in bytes.
     * @param type Optionally specified content type, by default infer it from the URL.
     */
    public function add (name :String, url :String, bytes :Int = 0, ?type :AssetType) :AssetEntry
    {
        if (type == null) {
            type = inferType(url);
        }

        var entry = new AssetEntry(name, url, type, bytes);
        _entries.push(entry);
        return entry;
    }

    /**
     * Iterates over all the assets defined in this manifest.
     */
    inline public function iterator () :Iterator<AssetEntry>
    {
        return _entries.iterator();
    }

    /**
     * Creates a copy of this manifest.
     */
    public function clone () :Manifest
    {
        var copy = new Manifest();
        copy.relativeBasePath = relativeBasePath;
        copy.externalBasePath = externalBasePath;
        copy._entries = _entries.copy();
        return copy;
    }

    /**
     * Get the full URL to load an asset from. May prepend relativeBasePath or externalBasePath
     * depending on cross-domain support and the asset type.
     */
    public function getFullURL (entry :AssetEntry) :String
    {
        var restricted = (externalBasePath != null && _supportsCrossOrigin) ?
            externalBasePath : relativeBasePath;
        var unrestricted = (externalBasePath != null) ? externalBasePath : relativeBasePath;

        var base = unrestricted;
#if html
        if (entry.type == Data) {
            // Without CORS, readable data must be loaded from the same origin
            // TODO(bruno): Do this for Images too, required for readPixels.
            base = restricted;
        }
#end
        return (base != null) ? base.joinPath(entry.url) : entry.url;
    }

    private function get_relativeBasePath () :String
    {
        return _relativeBasePath;
    }

    private function set_relativeBasePath (basePath :String) :String
    {
        _relativeBasePath = basePath;
        if (basePath != null) {
            Assert.that(!basePath.startsWith("http://") && !basePath.startsWith("https://"),
                "relativeBasePath must be a relative path on the same domain, NOT starting with http(s)://");
        }
        return basePath;
    }

    private function get_externalBasePath () :String
    {
        return _externalBasePath;
    }

    private function set_externalBasePath (basePath :String) :String
    {
        _externalBasePath = basePath;
        if (basePath != null) {
            Assert.that(basePath.startsWith("http://") || basePath.startsWith("https://"),
                "externalBasePath must be on an external domain, starting with http(s)://");
        }
        return basePath;
    }

    private static function inferType (url :String) :AssetType
    {
        var extension = url.split("?")[0].getFileExtension();
        if (extension != null) {
            switch (extension.toLowerCase()) {
                case "webp", "jxr", "png", "jpg", "gif": return Image;
                case "ogg", "m4a", "mp3", "wav": return Audio;
            }
        }
        return Data;
    }

    private static function createBuildManifests ()
    {
        var macroData = new Map<String,Array<Dynamic>>();
        ManifestBuilder.populate(macroData);

        var manifests = new Map();
        for (packName in macroData.keys()) {
            var manifest = new Manifest();
            manifest.relativeBasePath = "assets";

            for (asset in macroData.get(packName)) {
                var name = asset.name;
                var path = packName + "/" + name + "?v=" + asset.md5;

                var type = inferType(name);
                if (type == Image || type == Audio) {
                    // If this an asset that not all platforms may support, trim the extension from
                    // the name. We'll only load one of the assets if this creates a name collision.
                    name = name.removeFileExtension();
                }

                manifest.add(name, path, asset.bytes, type);
            }
            manifests.set(packName, manifest);
        }
        return manifests;
    }

    private static var _buildManifest :Map<String,Manifest> = createBuildManifests();

    // Whether the environment fully supports loading assets from another domain
    private static var _supportsCrossOrigin :Bool = (function () {
#if html
        // CORS in the stock Android browser is buggy. If your game is contained in an iframe, XHR
        // will work the first time. If the response had an Expires header, on subsequent page loads
        // instead of retrieving it from the cache, it will fail with error code 0.
        // http://stackoverflow.com/questions/6090816/android-cors-requests-work-only-once
        //
        // TODO(bruno): Better UA detection that only blacklists the stock browser, not Chrome or FF
        // for Android
        var blacklist = ~/\b(Android)\b/;
        if (blacklist.match(js.Browser.window.navigator.userAgent)) {
            return false;
        }

        var xhr :Dynamic = untyped __new__("XMLHttpRequest");
        return (xhr.withCredentials != null);
#else
        // Assumes you have a valid crossdomain.xml
        return true;
#end
    })();

    private var _entries :Array<AssetEntry>;

    private var _relativeBasePath :String;
    private var _externalBasePath :String;
}
