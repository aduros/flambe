//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;
using flambe.util.Iterables;
#end

class ComponentBuilder
{
    @:macro public static function build () :Array<Field>
    {
        var pos = Context.currentPos();
        var cl = Context.getLocalClass().get();

        var code =
            "var static__inline__NAME :String = '" + getComponentName(cl) + "';" +

            "function public__static__inline__getFrom (entity :flambe.Entity) :" + cl.name + " {" +
                "return cast entity.getComponent(NAME);" +
            "}" +

            "function public__static__inline__hasIn (entity :flambe.Entity) :Bool {" +
                "return (entity.getComponent(NAME) != null);" +
            "}" +

            "function override__public__getName () :String {" +
                "return NAME;" +
            "}";

        var fields = buildFields(code);
        return Context.getBuildFields().concat(fields);
    }

#if macro
    private static function getDefaultComponentName (cl :ClassType) :String
    {
        var compName = null;
        while (cl.name != "Component") {
            compName = cl.name;
            cl = cl.superClass.t.get();
        }
        return compName;
    }

    private static function getMetaComponentName (cl :ClassType) :String
    {
        var tag = cl.meta.get().find(function (t) return t.name == "compName");
        if (tag != null) {
            // Also remove this metadata from being compiled
            cl.meta.remove("compName");
            switch (tag.params[0].expr) {
                case EConst(c):
                    switch (c) {
                        case CString(v):
                            return v;
                        default: // Ignore
                    }
                default: // Ignore
            }
            Context.error("@compName param must be a string", Context.currentPos());
        }
        return null;
    }

    private static function getComponentName (cl :ClassType) :String
    {
        var compName = getMetaComponentName(cl);
        if (compName == null) {
            compName = getDefaultComponentName(cl);
        }
        return compName;
    }

    /**
     * Creates a list of fields from a source code string.
     */
    private static function buildFields (code :String) :Array<Field>
    {
        var block = Context.parse("{" + code + "}", Context.currentPos());
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
#end
}
