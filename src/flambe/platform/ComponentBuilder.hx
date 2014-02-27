//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

import flambe.util.Macros;

using Lambda;
using flambe.util.Iterables;

class ComponentBuilder
{
    public static function build () :Array<Field>
    {
        var pos = Context.currentPos();
        var cl = Context.getLocalClass().get();

        var name = Context.makeExpr(getComponentName(cl), pos);
        var componentType = TPath({pack: cl.pack, name: cl.name, params: []});

        var fields = Macros.buildFields(macro {
            #if doc @:noDoc #end
            var public__static__inline__NAME = $name;
        });

        // Only override get_name if this component directly extends a @:componentBase and creates a
        // new namespace
        if (extendsComponentBase(cl)) {
            fields = fields.concat(Macros.buildFields(macro {
                function override__private__get_name () :String {
                    return $name;
                }
            }));
        }

        return fields.concat(Context.getBuildFields());
    }

    private static function getComponentName (cl :ClassType) :String
    {
        // Traverse up to the last non-component base
        while (true) {
            if (extendsComponentBase(cl)) {
                break;
            }
            cl = cl.superClass.t.get();
        }

        // Look up the ID, otherwise generate one
        var fullName = cl.pack.concat([cl.name]).join(".");
        var name = _nameCache.get(fullName);
        if (name == null) {
            name = cl.name + "_" + _nextId;
            _nameCache.set(fullName, name);
            ++_nextId;
        }

        return name;
    }

    private static function extendsComponentBase (cl :ClassType)
    {
        var superClass = cl.superClass.t.get();
        return superClass.meta.has(":componentBase");
    }

    private static var _nameCache = new Map<String,String>();
    private static var _nextId = 0;
}
