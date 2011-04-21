package flambe.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;
using flambe.util.Iterables;
#end

class Build
{
    @:macro public static function buildComponent ()
    {
        var pos = Context.currentPos();
        var cl = Context.getLocalClass().get();
        var name = cl.name;

        // TODO: Putting this in a file and using haxe.Template would be sweet
        var code =
            "var static__inline__NAME :String = '" + getComponentName(cl) + "';" +

            "function public__static__inline__get" + name + " (entity :flambe.Entity) :" + name + " {" +
                "return cast entity.getComponent(NAME);" +
            "}" +

            "function public__static__inline__with" + name + " (entity :flambe.Entity) :flambe.Entity {" +
                "entity.addComponent(new " + name + "());" +
                "return entity;" +
            "}" +

            "function public__static__inline__has" + name + " (entity :flambe.Entity) :Bool {" +
                "return (entity.getComponent(NAME) != null);" +
            "}" +

            "function public__static__require" + name + " (entity :flambe.Entity) :" + name + " {" +
                "var comp :" + name + " = get" + name + "(entity);" +
                "if (comp == null) {" +
                    "comp = new " + name + "();" +
                    "entity.addComponent(comp);" +
                "}" +
                "return comp;" +
            "}" +

            "function override__public__getName () :String {" +
                "return NAME;" +
            "}";

        return Context.parse("{" + code + "}", pos);
    }

#if macro
    public static function getDefaultComponentName (cl :ClassType) :String
    {
        var compName = null;
        while (cl.name != "Component") {
            compName = cl.name;
            cl = cl.superClass.t.get();
        }
        return compName;
    }

    public static function getMetaComponentName (cl :ClassType) :String
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

    public static function getComponentName (cl :ClassType) :String
    {
        var compName = getMetaComponentName(cl);
        if (compName == null) {
            compName = getDefaultComponentName(cl);
        }
        return compName;
    }
#end
}
