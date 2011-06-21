//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe;

#if macro
import haxe.macro.Expr;
#end

import flambe.util.Disposable;

using Lambda;

class Entity
#if !macro // Don't require us to implement these interfaces when running in the macro emulator
    implements Disposable
#end
{
    @:macro
    public function get (self :Expr, componentType :Expr)
    {
        // self.get(componentType) --> componentType.getFrom(self)
        return {
            expr: ECall({
                expr: EType(componentType, "getFrom"),
                pos: self.pos
            }, [ self ]),
            pos: self.pos
        };
    }

    @:macro
    public function has (self :Expr, componentType :Expr)
    {
        // self.has(componentType) --> componentType.hasIn(self)
        return {
            expr: ECall({
                expr: EType(componentType, "hasIn"),
                pos: self.pos
            }, [ self ]),
            pos: self.pos
        };
    }

#if !macro
    public var parent (default, null) :Entity;

    public function new ()
    {
        _comps = [];
#if flash
	_compMap = cast new flash.utils.Dictionary();
#elseif js
	_compMap = {};
#end
        _children = [];
    }

    public function add (comp :Component) :Entity
    {
        var name = comp.getName();
        if (getComponent(name) == null) {
            untyped _compMap[name] = comp;
            _comps.push(comp);

            comp._internal_setOwner(this);
            comp.onAdded();
        }
        return this;
    }

    public function remove (comp :Component)
    {
        if (comp.owner == this) {
            var name = comp.getName();
#if flash
            untyped __delete__(_compMap, name);
#elseif js
	    untyped __js__("delete")(_compMap.name);
#end
            var idx = _comps.indexOf(comp);
            if (idx >= 0) {
                _comps[idx] = null;
            }
            comp.onRemoved();
            comp._internal_setOwner(null);
        }
    }

    inline public function getComponent (name :String) :Component
    {
        return untyped _compMap[name];
    }

    public function visit (visitor :Visitor, visitComponents :Bool, visitChildren :Bool)
    {
        if (!visitor.enterEntity(this)) {
            return;
        }

        if (visitComponents) {
            var ii = 0;
            while (ii < _comps.length) {
                var comp = _comps[ii];
                if (comp == null) {
                    _comps.splice(ii, 1);
                } else {
                    visitor.acceptComponent(comp);
                    ++ii;
                }
            }
        }
        if (visitChildren) {
            var ii = 0;
            while (ii < _children.length) {
                var child = _children[ii];
                if (child == null) {
                    _children.splice(ii, 1);
                } else {
                    child.visit(visitor, visitComponents, visitChildren);
                    ++ii;
                }
            }
        }

        visitor.leaveEntity(this);
    }

    public function addChild (entity :Entity)
    {
        if (entity.parent != null) {
            entity.parent.removeChild(entity);
        }
        entity.parent = this;
        _children.push(entity);
    }

    public function removeChild (entity :Entity)
    {
        var idx = _children.indexOf(entity);
        if (idx >= 0) {
            _children[idx] = null;
            entity.parent = null;
        }
    }

    public function dispose ()
    {
        if (parent != null) {
            parent.removeChild(this);
        }

        var ii = 0;
        while (ii < _comps.length) {
            var comp = _comps[ii];
            if (comp != null) {
                _comps[ii] = null;
                comp.onRemoved();
                comp._internal_setOwner(null);
                comp.onDispose();
            }
            ++ii;
        }
        var ii = 0;
        while (ii < _children.length) {
            var child = _children[ii];
            if (child != null) {
                _children[ii] = null;
                child.parent = null;
                child.dispose();
            }
        }
    }

    /**
     * Maps String -> Component. Usually you would use a haXe Hash here, but I'm dropping down to plain
     * Object/Dictionary for the quickest possible lookups in this critical part of Flambe.
     */
    private var _compMap :Dynamic<Component>;

    private var _comps :Array<Component>;

    private var _parent :Entity;
    private var _children :Array<Entity>;
#end // if !macro
}
