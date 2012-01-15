//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.macro;

#if macro
import neko.FileSystem;
import neko.io.File;
import neko.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using flambe.macro.Macros;
using flambe.util.Strings;
using Lambda;
using StringTools;
#end

/**
 * Creates the asset manifests from the files in /assets
 */
class ManifestBuilder
{
    @:macro
    public static function populate (hash :Expr)
    {
        var assetDir = "../assets/";
        var exprs :Array<Expr> = [];
        var hash_set = EField(hash, "set").toExpr();

        for (packName in readDirectoryNoHidden(assetDir)) {
            var entries :Array<Expr> = [];
            if (FileSystem.isDirectory(assetDir + packName)) {
                for (file in readRecursive(assetDir + packName)) {
                    var name = file;
                    var path = assetDir + packName + "/" + file;
                    var md5 = Context.signature(File.getBytes(path));
                    var bytes = FileSystem.stat(path).size;

                    // Assemble the object literal for this asset
                    var entry = EObjectDecl([
                        { field: "name", expr: name.toExpr() },
                        { field: "md5", expr: md5.toExpr() },
                        { field: "bytes", expr: bytes.toExpr() }
                    ]);
                    entries.push(entry.toExpr());
                }

                // Build a pack with a list of file entries
                exprs.push(ECall(hash_set, [ packName.toExpr(),
                    EArrayDecl(entries).toExpr() ]).toExpr());
            }
        }

        return EBlock(exprs).toExpr();
    }

#if macro
    public static function readRecursive (root, dir = ".")
    {
        var result = [];
        for (file in readDirectoryNoHidden(root + "/" + dir)) {
            var fullPath = root + "/" + dir + "/" + file;
            var relPath = if (dir == ".") file else dir + "/" + file;
            if (FileSystem.isDirectory(fullPath)) {
                result = result.concat(readRecursive(root, relPath));
            } else {
                result.push(relPath);
            }
        }
        return result;
    }

    public static function readDirectoryNoHidden (dir)
    {
        return FileSystem.exists(dir) && FileSystem.isDirectory(dir) ?
            FileSystem.readDirectory(dir).filter(function (file) return file.charAt(0) != ".") :
            cast [];
    }
#end
}
