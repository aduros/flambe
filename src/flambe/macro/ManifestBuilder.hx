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

using Lambda;
using StringTools;
#end

class ManifestBuilder
{
    @:macro
    public static function populateManifest (manifest :Expr)
    {
        var assetDir = "../res/";
        var exprs :Array<Expr> = [];
        var set = exprOf(EField(manifest, "set"));

        for (packName in readDirectoryNoHidden(assetDir)) {
            var entries :Array<Expr> = [];
            if (FileSystem.isDirectory(assetDir + packName)) {
                for (file in readRecursive(assetDir + packName)) {
                    var name = file;
                    var url = packName + "/" + file;
                    var bytes = FileSystem.stat(assetDir + packName + "/" + file).size;
                    var type = file.toLowerCase().endsWith(".png") ? "Image" : "Data";

                    // Assemble the object literal for this file
                    var fileObject = exprOf(EObjectDecl([
                        { field: "name", expr: string(name) },
                        { field: "url", expr: string(url) },
                        { field: "type", expr: exprOf(EConst(CIdent(type))) },
                        { field: "bytes", expr: int(bytes) }
                    ]));
                    entries.push(fileObject);
                }

                // Build a pack with a list of file entries
                exprs.push(exprOf(ECall(set, [ string(packName), array(entries) ])));
            }
        }

        return exprOf(EBlock(exprs));
    }

#if macro
    public static function string (str :String) :Expr
    {
        return exprOf(EConst(CString(str)));
    }

    public static function int (n :Int) :Expr
    {
        // OMFG
        return exprOf(EConst(CInt(Std.string(n))));
    }

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

    public static function readDirectoryNoHidden (dir)
    {
        return FileSystem.readDirectory(dir).filter(function (file) return file.charAt(0) != ".");
    }
#end
}
