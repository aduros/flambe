package flambe;

import haxe.macro.Expr;

class Entity
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

            comp.onAttach(this);
        }
        return this;
    }

    public function removeComponent (comp :Component)
    {
        var name = comp.getName();
        if (comp.owner == this) {
#if flash
            untyped __delete__(_compMap, name);
#elseif js
	    untyped __js__("delete")(_compMap.name);
#end
            _comps.remove(comp);
            comp.onDetach();
        }
    }

    inline public function getComponent (name :String) :Component
    {
        return untyped _compMap[name];
    }

    public function visit (visitor :Visitor)
    {
        visitor.enterEntity(this);
        for (comp in _comps) {
            visitor.acceptComponent(comp);
            comp.visit(visitor);
        }
        for (child in _children) {
            child.visit(visitor);
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
        if (_children.remove(entity)) {
            entity.parent = null;
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
