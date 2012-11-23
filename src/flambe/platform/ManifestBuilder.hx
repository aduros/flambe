//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

#if macro
import neko.FileSystem;
import neko.io.File;
import neko.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using flambe.util.Strings;
using Lambda;
using StringTools;
using Type;
#end

/**
 * Creates the asset manifests from the files in /assets
 */
class ManifestBuilder
{
    @:macro public static function populate (hash :Expr) :Expr
    {
        if (Context.defined("display")) {
            // When running in code completion, skip out early
            return toExpr(EBlock([]));
        }

#if nme_install_tool
        var assetPrefix = "assets/";
#else
        var assetPrefix = "../assets/";
#end
        var exprs :Array<Expr> = [];
        var hash_set = toExpr(EField(hash, "set"));
        for (packName in readDirectoryNoHidden(assetPrefix)) {
            var entries :Array<Expr> = [];
            if (FileSystem.isDirectory(assetPrefix + packName)) {
                for (file in readRecursive(assetPrefix + packName)) {
                    var name = file;
                    var path = assetPrefix + packName + "/" + file;
                    var md5 = Context.signature(File.getBytes(path));
                    var bytes = FileSystem.stat(path).size;

                    // Assemble the object literal for this asset
                    var entry = EObjectDecl([
                        { field: "name", expr: toExpr(name) },
                        { field: "md5", expr: toExpr(md5) },
                        { field: "bytes", expr: toExpr(bytes) }
                    ]);
                    entries.push(toExpr(entry));
                }

                // Build a pack with a list of file entries
                exprs.push(toExpr(ECall(hash_set, [ toExpr(packName),
                    toExpr(EArrayDecl(entries)) ])));
            }
        }

        return toExpr(EBlock(exprs));
    }

#if macro
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

    public static function toExpr (object :Dynamic) :Expr
    {
        var pos = Context.currentPos();

        // If it's an ExprDef, use it directly
        var e :EnumValue = cast object;
        if (e.getEnum() == ExprDef) {
            var exprDef = cast object;
            return { expr: object, pos: pos };
        }

        return Context.makeExpr(object, pos);
    }
#end
}
