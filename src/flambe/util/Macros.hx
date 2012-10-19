//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

/**
 * Utilities for Haxe macros.
 */
class Macros
{
    /**
     * Creates a list of fields from a block expression.
     */
    public static function buildFields (block :Expr) :Array<Field>
    {
        var fields :Array<Field> = [];
        switch (block.expr) {
            case EBlock(exprs):
                for (expr in exprs) {
                    switch (expr.expr) {
                        case EVars(vars):
                            for (v in vars) {
                                fields.push({
                                    name: getFieldName(v.name),
                                    doc: null,
                                    access: getAccess(v.name),
                                    kind: FVar(v.type, v.expr),
                                    pos: v.expr.pos,
                                    meta: []
                                });
                            }
                        case EFunction(name, f):
                            fields.push({
                                name: getFieldName(name),
                                doc: null,
                                access: getAccess(name),
                                kind: FFun(f),
                                pos: f.expr.pos,
                                meta: []
                            });
                        default:
                    }
                }
            default:
        }
        return fields;
    }

    private static function getAccess (name :String) :Array<Access>
    {
        var result = [];
        for (token in name.split("__")) {
            var access = switch (token) {
                case "public": APublic;
                case "private": APrivate;
                case "static": AStatic;
                case "override": AOverride;
                case "dynamic": ADynamic;
                case "inline": AInline;
                default: null;
            }
            if (access != null) {
                result.push(access);
            }
        }
        return result;
    }

    private static function getFieldName (name :String) :String
    {
        var idx = name.lastIndexOf("__");
        return (idx < 0) ? name : name.substr(idx + 2);
    }
}
