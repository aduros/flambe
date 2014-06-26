//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import haxe.rtti.Meta;

import flambe.asset.AssetEntry;
import flambe.util.Assert;

using StringTools;
using flambe.util.Strings;

/**
 * An asset manifest contains all the information needed to load an asset pack. A manifest is
 * usually created with `Manifest.fromAssets("directory")`, but manifests can also be assembled
 * programmatically.
 */
class Manifest
{
    /**
     * A base path on the current domain to load this manifest's assets from, or null.
     */
    public var localBase (get, set) :String;

    /**
     * A base URL on another domain to load this manifest's assets from, or null. May be used to
     * load assets from a CDN, in browsers that support cross-domain requests. If not supported or
     * unset, will fallback to using localBase.
     */
    public var remoteBase (get, set) :String;

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
    public static function fromAssets (packName :String, required :Bool = true) :Manifest
    {
        var packData :Array<Dynamic> = Reflect.field(Meta.getType(Manifest).assets[0], packName);
        if (packData == null) {
            if (required) {
                throw "Missing asset pack".withFields(["name", packName]);
            }
            return null;
        }

        var manifest = new Manifest();
        manifest.localBase = "assets";

        for (asset in packData) {
            var name = asset.name;
            var path = packName + "/" + name + "?v=" + asset.md5;

            var format = inferFormat(name);
            if (format != Data) {
                // If this an asset that not all platforms may support, trim the extension from
                // the name. We'll only load one of the assets if this creates a name collision.
                name = name.removeFileExtension();
            }

            manifest.add(name, path, asset.bytes, format);
        }

        return manifest;
    }

    /**
     * Tries to find a pack suffixed with the closest available variant of the locale. For example,
     * fromAssetsLocalized("foo", "pt-BR") will first try to load foo_pt-BR, then foo_pt, then just
     * foo.
     * @param packName The folder name in your assets/ directory.
     * @param locale An RFC 4646 language tag, or null to use the system language.
     * @param required When true and this pack was not found, throw an error. Otherwise null is
     *   returned.
     */
    public static function fromAssetsLocalized (
        packName :String, locale :String = null, required :Bool = true) :Manifest
    {
        if (locale == null) {
            locale = System.locale;
        }

        if (locale != null) {
            var parts = locale.split("-");
            while (parts.length > 0) {
                var manifest = fromAssets(packName + "_" + parts.join("-"), false);
                if (manifest != null) {
                    return manifest;
                }
                parts.pop();
            }
        }
        return fromAssets(packName, required);
    }

    /**
     * Returns true if the given named pack was included in the asset directory at build-time.
     */
    public static function exists (packName :String) :Bool
    {
        return Reflect.hasField(Meta.getType(Manifest).assets[0], packName);
    }

    /**
     * Adds an asset entry to this manifest.
     * @param name The name of the asset.
     * @param url The URL this asset will be downloaded from.
     * @param bytes The size in bytes.
     * @param format Optionally specified content format, by default infer it from the URL.
     */
    public function add (name :String, url :String, bytes :Int = 0, ?format :AssetFormat) :AssetEntry
    {
        if (format == null) {
            format = inferFormat(url);
        }

        var entry = new AssetEntry(name, url, format, bytes);
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
        copy.localBase = localBase;
        copy.remoteBase = remoteBase;
        copy._entries = _entries.copy();
        return copy;
    }

    /**
     * Get the full URL to load an asset from. Will prepend localBase or remoteBase depending on
     * cross-domain support.
     */
    public function getFullURL (entry :AssetEntry) :String
    {
        var basePath = (remoteBase != null && _supportsCrossOrigin) ? remoteBase : localBase;
        return (basePath != null) ? basePath.joinPath(entry.url) : entry.url;
    }

    private function get_localBase () :String
    {
        return _localBase;
    }

    private function set_localBase (localBase :String) :String
    {
        if (localBase != null) {
            Assert.that(!localBase.startsWith("http://") && !localBase.startsWith("https://"),
                "localBase must be a path on the same domain, NOT starting with http(s)://");
        }
        return _localBase = localBase;
    }

    private function get_remoteBase () :String
    {
        return _remoteBase;
    }

    private function set_remoteBase (remoteBase :String) :String
    {
        if (remoteBase != null) {
            Assert.that(remoteBase.startsWith("http://") || remoteBase.startsWith("https://"),
                "remoteBase must be on a remote domain, starting with http(s)://");
        }
        return _remoteBase = remoteBase;
    }

    private static function inferFormat (url :String) :AssetFormat
    {
        var extension = url.getUrlExtension();
        if (extension != null) {
            switch (extension.toLowerCase()) {
                case "gif": return GIF;
                case "jpg", "jpeg": return JPG;
                case "jxr", "wdp": return JXR;
                case "png": return PNG;
                case "webp": return WEBP;

                case "dds": return DDS;
                case "pvr": return PVR;
                case "pkm": return PKM;

                case "m4a": return M4A;
                case "mp3": return MP3;
                case "ogg": return OGG;
                case "opus": return OPUS;
                case "wav": return WAV;
            }
        } else {
            Log.warn("No file extension for asset, it will be loaded as data", ["url", url]);
        }
        return Data;
    }

    // Whether the environment fully supports loading assets from another domain
    private static var _supportsCrossOrigin :Bool = (function () {
        var detected =
#if html
        (function () {
            // CORS in the stock Android browser is buggy. If your game is contained in an iframe, XHR
            // will work the first time. If the response had an Expires header, on subsequent page loads
            // instead of retrieving it from the cache, it will fail with error code 0.
            // http://stackoverflow.com/questions/6090816/android-cors-requests-work-only-once
            if (js.Browser.navigator.userAgent.indexOf("Linux; U; Android") >= 0) {
                return false;
            }

            var xhr :Dynamic = untyped __new__("XMLHttpRequest");
            return (xhr.withCredentials != null);
        })();
#else
            true; // Assumes you have a valid crossdomain.xml
#end
        if (!detected) {
            Log.warn("This browser does not support cross-domain asset loading, any Manifest.remoteBase setting will be ignored.");
        }
        return detected;
    })();

    private var _entries :Array<AssetEntry>;

    private var _localBase :String = null;
    private var _remoteBase :String = null;
}
