//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

#if macro
import haxe.macro.Expr;
#end

import flambe.util.Disposable;

using Lambda;

/**
 * <p>A node in the entity hierarchy, and a collection of components.</p>
 *
 * <p>To iterate over the hierarchy, use the parent, firstChild, next and firstComponent fields. For
 * example:</p>
 *
 * <pre>
 * // Iterate over entity's children
 * var child = entity.firstChild;
 * while (child != null) {
 *     var next = child.next; // Store in case the child is removed in process()
 *     process(child);
 *     child = next;
 * }
 * </pre>
 */
class Entity
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
     * Add a component to this entity.
     * @returns This instance, for chaining.
     */
    public function add (component :Component) :Entity
    {
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
            tail._internal_setNext(component);
        } else {
            firstComponent = component;
        }

        component._internal_init(this, null);
        component.onAdded();

        return this;
    }

    /**
     * Remove a component from this entity.
     */
    public function remove (component :Component)
    {
        var prev :Component = null, p = firstComponent;
        while (p != null) {
            var next = p.next;
            if (p == component) {
                // Splice out the component
                if (prev == null) {
                    firstComponent = next;
                } else {
                    prev._internal_init(this, next);
                }

                // Remove it from the _compMap
#if flash
                untyped __delete__(_compMap, p.name);
#elseif js
                untyped __js__("delete")(_compMap[p.name]);
#end

                // Notify the component it was removed
                p.onRemoved();
                p._internal_init(null, null);
                return;
            }
            prev = p;
            p = next;
        }
    }

    /**
     * Gets a component of a given class from this entity.
     */
    @:macro
    public function get<A> (self :Expr, componentClass :ExprRequire<Class<A>>) :ExprRequire<A>
    {
        // Rewrites self.get(ComponentClass) to ComponentClass.getFrom(self)
        return {
            expr: ECall({
                expr: EType(componentClass, "getFrom"),
                pos: self.pos
            }, [ self ]),
            pos: self.pos
        };
    }

    /**
     * Checks if this entity has a component of the given class.
     */
    @:macro
    public function has<A> (self :Expr, componentClass :ExprRequire<Class<A>>) :ExprRequire<Bool>
    {
        // Rewrites self.has(ComponentClass) to ComponentClass.hasIn(self)
        return {
            expr: ECall({
                expr: EType(componentClass, "hasIn"),
                pos: self.pos
            }, [ self ]),
            pos: self.pos
        };
    }

    /**
     * Gets a component by name from this entity.
     */
    inline public function getComponent (name :String) :Component
    {
        return untyped _compMap[name];
    }

    /**
     * Adds a child to this entity.
     * @returns This instance, for chaining.
     */
    public function addChild (entity :Entity)
    {
        if (entity.parent != null) {
            entity.parent.removeChild(entity);
        }
        entity.parent = this;

        // Append it to the sibling list
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
            var next = firstChild.next;
            firstChild.dispose();
            firstChild = next;
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
            var next = firstComponent.next;
#if flash
            untyped __delete__(_compMap, firstComponent.name);
#elseif js
            untyped __js__("delete")(_compMap[firstComponent.name]);
#end

            firstComponent.onRemoved();
            firstComponent._internal_init(null, null);
            firstComponent = next;
        }

        disposeChildren();
    }

#if debug
    @:keep public function toString () :String
    {
        return toStringImpl("");
    }
#end

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

    /**
     * Maps String -> Component. Usually you would use a Haxe Hash here, but I'm dropping down to plain
     * Object/Dictionary for the quickest possible lookups in this critical part of Flambe.
     */
    private var _compMap :Dynamic<Component>;
}
