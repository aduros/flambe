//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.asset.AssetEntry;
import flambe.macro.ManifestBuilder;

using flambe.util.Strings;

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
    public static function buildLocalized (packName :String, locale :String = null)
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

    public function add (name :String, url :String, bytes :Int = 0, ?type :AssetType)
    {
        if (type == null) {
            // Infer the type from the url
            type = switch (url.toLowerCase().getFileExtension()) {
                case "png", "jpg", "gif": Image;
                default: Data;
            };
        }

        _entries.push(new AssetEntry(name, url, type, bytes));
    }

    public function getEntries () :Array<AssetEntry>
    {
        return _entries.copy();
    }

    private static function createBuildManifests ()
    {
        var macroData = new Hash<Array<Dynamic>>();
        ManifestBuilder.populate(macroData);

        var manifests = new Hash();
        for (packName in macroData.keys()) {
            var manifest = new Manifest();
            for (asset in macroData.get(packName)) {
                manifest.add(asset.name, asset.url, asset.bytes);
            }
            manifests.set(packName, manifest);
        }
        return manifests;
    }

    private static var _buildManifest :Hash<Manifest> = createBuildManifests();

    private var _entries :Array<AssetEntry>;
}
