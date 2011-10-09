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

    // Get a manifest of an asset pack in /res
    public static function res (packName :String)
    {
        return _macroManifests.get(packName);
    }

    public function add (name :String, url :String, bytes :Int = 0, ?type :AssetType)
    {
        if (type == null) {
            // Infer the type from the url
            type = switch (url.getFileExtension()) {
                case "png", "jpg": Image;
                default: Data;
            };
        }

        _entries.push(new AssetEntry(name, url, type, bytes));
    }

    public function getEntries () :Array<AssetEntry>
    {
        return _entries.copy();
    }

    private static function createMacroManifests ()
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

    private static var _macroManifests :Hash<Manifest> = createMacroManifests();

    private var _entries :Array<AssetEntry>;
}
