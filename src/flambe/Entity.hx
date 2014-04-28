//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;
#end

import flambe.util.Disposable;

using Lambda;

/**
 * A node in the entity hierarchy, and a collection of components.
 *
 * To iterate over the hierarchy, use the parent, firstChild, next and firstComponent fields. For
 * example:
 *
 * ```haxe
 * // Iterate over entity's children
 * var child = entity.firstChild;
 * while (child != null) {
 *     var next = child.next; // Store in case the child is removed in process()
 *     process(child);
 *     child = next;
 * }
 * ```
 */
@:final class Entity
    implements Disposable
{
    /** This entity's parent. */
    public var parent (default, null) :Entity = null;

    /** This entity's first child. */
    public var firstChild (default, null) :Entity = null;

    /** This entity's next sibling, for iteration. */
    public var next (default, null) :Entity = null;

    /** This entity's first component. */
    public var firstComponent (default, null) :Component = null;

    public function new ()
    {
#if flash
        _compMap = cast new flash.utils.Dictionary();
#elseif js
        _compMap = {};
#end
    }

    /**
     * Add a component to this entity. Any previous component of this type will be replaced.
     * @returns This instance, for chaining.
     */
    public function add (component :Component) :Entity
    {
        // Remove the component from any previous owner. Don't just call dispose, which has
        // additional behavior in some components (like Disposer).
        if (component.owner != null) {
            component.owner.remove(component);
        }

        var name = component.name;
        var prev = getComponent(name);
        if (prev != null) {
            // Remove the previous component under this name
            remove(prev);
        }

        untyped _compMap[name] = component;

        // Append it to the component list
        var tail = null, p = firstComponent;
        while (p != null) {
            tail = p;
            p = p.next;
        }
        if (tail != null) {
            tail.setNext(component);
        } else {
            firstComponent = component;
        }

        component.init(this, null);
        component.onAdded();

        return this;
    }

    /**
     * Remove a component from this entity.
     * @return Whether the component was removed.
     */
    public function remove (component :Component) :Bool
    {
        var prev :Component = null, p = firstComponent;
        while (p != null) {
            var next = p.next;
            if (p == component) {
                // Splice out the component
                if (prev == null) {
                    firstComponent = next;
                } else {
                    prev.init(this, next);
                }

                // Remove it from the _compMap
#if flash
                untyped __delete__(_compMap, p.name);
#elseif js
                untyped __js__("delete")(_compMap[p.name]);
#end

                // Notify the component it was removed
                p.onRemoved();
                p.init(null, null);
                return true;
            }
            prev = p;
            p = next;
        }
        return false;
    }

    /**
     * Gets a component of a given type from this entity.
     */
#if (display || dox)
    public function get<A:Component> (componentClass :Class<A>) :A return null;

#else
    macro public function get<A> (self :Expr, componentClass :ExprOf<Class<A>>) :ExprOf<A>
    {
        var path = getClassPathFromExpr(componentClass);
        if (path != null)
        {
            var type = Context.getType(path.join("."));

            if (Context.unify(type, Context.getType("flambe.Component"))) {
                // Delegate through getComponentTyped to avoid a (slow) typed cast
                return macro $self._internal_getComponentTyped($componentClass.NAME, $componentClass);
            }            
        }

        Context.error("Expected a class that extends Component, got " + componentClass.toString(),
            Context.currentPos());
        return null;
    }

#if macro
    static function getClassPathFromExpr<A> (componentClass :ExprOf<Class<A>>) :Array<String>
    {
        switch (componentClass.expr) {
        case EConst(CIdent(name)):
            return [name];
        case EField(e, name):
            var path = getClassPathFromExpr(e);
            if (path != null)
                path.push(name);
            return path;
        default:
            return null;
        }
    }
#end

#end

    /**
     * Checks if this entity has a component of the given type.
     */
#if (display || dox)
    public function has<A:Component> (componentClass :Class<A>) :Bool return false;

#else
    macro public function has<A> (self :Expr, componentClass :ExprOf<Class<A>>) :ExprOf<Bool>
    {
        return macro $self.get($componentClass) != null;
    }
#end

    /**
     * Gets a component by name from this entity.
     */
    inline public function getComponent (name :String) :Component
    {
        return untyped _compMap[name];
    }

    /**
     * Adds a child to this entity.
     * @param append Whether to add the entity to the end or beginning of the child list.
     * @returns This instance, for chaining.
     */
    public function addChild (entity :Entity, append :Bool=true) :Entity
    {
        if (entity.parent != null) {
            entity.parent.removeChild(entity);
        }
        entity.parent = this;

        if (append) {
            // Append it to the child list
            var tail = null, p = firstChild;
            while (p != null) {
                tail = p;
                p = p.next;
            }
            if (tail != null) {
                tail.next = entity;
            } else {
                firstChild = entity;
            }

        } else {
            // Prepend it to the child list
            entity.next = firstChild;
            firstChild = entity;
        }

        return this;
    }

    public function removeChild (entity :Entity)
    {
        var prev :Entity = null, p = firstChild;
        while (p != null) {
            var next = p.next;
            if (p == entity) {
                // Splice out the entity
                if (prev == null) {
                    firstChild = next;
                } else {
                    prev.next = next;
                }
                p.parent = null;
                p.next = null;
                return;
            }
            prev = p;
            p = next;
        }
    }

    /**
     * Dispose all of this entity's children, without touching its own components or removing itself
     * from its parent.
     */
    public function disposeChildren ()
    {
        while (firstChild != null) {
            firstChild.dispose();
        }
    }

    /**
     * Removes this entity from its parent, and disposes all its components and children.
     */
    public function dispose ()
    {
        if (parent != null) {
            parent.removeChild(this);
        }

        while (firstComponent != null) {
            firstComponent.dispose();
        }
        disposeChildren();
    }

    #if debug @:keep #end public function toString () :String
    {
        return toStringImpl("");
    }

    private function toStringImpl (indent :String) :String
    {
        var output = "";
        var p = firstComponent;
        while (p != null) {
            output += p.name;
            if (p.next != null) {
                output += ", ";
            }
            p = p.next;
        }
        output += "\n";

        // Oof, Haxe doesn't support escaped unicode in string literals
        var u2514 = String.fromCharCode(0x2514); // └
        var u241c = String.fromCharCode(0x251c); // ├
        var u2500 = String.fromCharCode(0x2500); // ─
        var u2502 = String.fromCharCode(0x2502); // │

        var p = firstChild;
        while (p != null) {
            var last = p.next == null;
            output += indent + (last ? u2514 : u241c) + u2500+u2500+" ";
            output += p.toStringImpl(indent + (last ? " " : u2502) + "   ");
            p = p.next;
        }
        return output;
    }

    // A semi-private helper method used by Entity.get()
#if !display
    @:extern // Inline even in debug builds
    inline public function _internal_getComponentTyped<A:Component> (name :String, cl :Class<A>) :A
    {
        return cast getComponent(name);
    }
#end

    /**
     * Maps String -> Component. Usually you would use a Haxe Map here, but I'm dropping down to plain
     * Object/Dictionary for the quickest possible lookups in this critical part of Flambe.
     */
    private var _compMap :Dynamic<Component>;
}
