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

        return Macros.buildFields(macro {
            function inline__public__static__getFrom (entity :flambe.Entity) :$componentType {
                return cast entity.getComponent($name);
            }

            function inline__public__static__hasIn (entity :flambe.Entity) :Bool {
                return entity.getComponent($name) != null;
            }

            function override__public__getName () :String {
                return $name;
            }
        }).concat(Context.getBuildFields());
    }

    private static function getComponentName (cl :ClassType) :String
    {
        // Traverse up to the last non-component base
        while (true) {
            var superClass = cl.superClass.t.get();
            if (superClass.meta.has(":componentBase")) {
                break;
            }
            cl = superClass;
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

    private static var _nameCache = new Hash<String>();
    private static var _nextId = 0;
}
