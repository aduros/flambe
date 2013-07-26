//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import sys.FileSystem;
import sys.io.File;

import haxe.macro.Context;

using StringTools;

/**
 * Creates the asset manifests from the files in /assets
 */
class ManifestBuilder
{
    macro public static function use (assetsDir :String)
    {
        switch (Context.getType("flambe.asset.Manifest")) {
        case TInst(cl,_):
            var cl = cl.get();
            var meta = cl.meta;

            if (!assetsDir.endsWith("/")) {
                assetsDir += "/";
            }

            var data = {};
            for (packName in FileSystem.readDirectory(assetsDir)) {
                var entries = [];
                if (FileSystem.isDirectory(assetsDir + packName)) {
                    for (file in readRecursive(assetsDir + packName)) {
                        var path = assetsDir + packName + "/" + file;
                        entries.push({
                            name: file,
                            md5: Context.signature(File.getBytes(path)),
                            bytes: FileSystem.stat(path).size,
                        });
                    }
                }
                Reflect.setField(data, packName, entries);
            }

            meta.remove("assets");
            meta.add("assets", [macro $v{data}], cl.pos);

        default:
            throw "assert";
        }

        return macro {};
    }

    private static function readRecursive (root, dir = "")
    {
        var result = [];
        for (file in readDirectoryNoHidden(root + "/" + dir)) {
            var fullPath = root + "/" + dir + "/" + file;
            var relPath = if (dir == "") file else dir + "/" + file;
            if (FileSystem.isDirectory(fullPath)) {
                result = result.concat(readRecursive(root, relPath));
            } else {
                result.push(relPath);
            }
        }
        return result;
    }

    private static function readDirectoryNoHidden (dir :String)
    {
        if (dir.fastCodeAt(dir.length - 1) == "/".code) {
            // Trim off the trailing slash. On Windows, FileSystem.exists() doesn't find directories
            // with trailing slashes?
            dir = dir.substr(0, -1);
        }
        return FileSystem.exists(dir) && FileSystem.isDirectory(dir) ?
            FileSystem.readDirectory(dir).filter(
                function (file) return file.fastCodeAt(0) != ".".code) :
            cast [];
    }
}
