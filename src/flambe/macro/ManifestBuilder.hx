//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.macro;

#if macro
import neko.FileSystem;
import neko.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using flambe.macro.Macros;
using Lambda;
using StringTools;
#end

/**
 * Creates the asset manifest from the files in /res
 */
class ManifestBuilder
{
    @:macro
    public static function populateManifest (manifest :Expr)
    {
        var assetDir = "../res/";
        var exprs :Array<Expr> = [];
        var setter = EField(manifest, "set").toExpr();

        for (packName in readDirectoryNoHidden(assetDir)) {
            var entries :Array<Expr> = [];
            if (FileSystem.isDirectory(assetDir + packName)) {
                for (file in readRecursive(assetDir + packName)) {
                    var name = file;
                    var url = packName + "/" + file;
                    var bytes = FileSystem.stat(assetDir + packName + "/" + file).size;
                    var type = switch (getExtension(file.toLowerCase())) {
                        case "png", "jpg": "Image";
                        default: "Data";
                    }

                    // Assemble the object literal for this file
                    var fileObject = exprOf(EObjectDecl([
                        { field: "name", expr: name.toExpr() },
                        { field: "url", expr: url.toExpr() },
                        { field: "type", expr: EConst(CIdent(type)).toExpr() },
                        { field: "bytes", expr: bytes.toExpr() }
                    ]));
                    entries.push(fileObject);
                }

                // Build a pack with a list of file entries
                exprs.push(ECall(setter, [ packName.toExpr(),
                    EArrayDecl(entries).toExpr() ]).toExpr());
            }
        }

        return EBlock(exprs).toExpr();
    }

#if macro
    public static function array (arr :Array<Expr>) :Expr
    {
        return exprOf(EArrayDecl(arr));
    }

    public static function exprOf (def :ExprDef) :Expr
    {
        return { expr: def, pos: Context.currentPos() };
    }

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

    public static function getExtension (fileName :String) :String
    {
        var start = fileName.lastIndexOf(".") + 1;
        return (start > 1 && start < fileName.length) ? fileName.substr(start) : null;
    }

    public static function readDirectoryNoHidden (dir)
    {
        return FileSystem.readDirectory(dir).filter(function (file) return file.charAt(0) != ".");
    }
#end
}
