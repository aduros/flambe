//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Disposable;

/**
 * Components are bits of data and logic that can be added to entities.
 */
#if (!macro && !display)
@:autoBuild(flambe.platform.ComponentBuilder.build())
#end
@:componentBase
class Component
    implements Disposable
{
    /** The entity this component is attached to, or null. */
    public var owner (default, null) :Entity;

    /** The owner's next component, for iteration. */
    public var next (default, null) :Component;

    /**
     * The component's name, generated based on its class. Components with the same name replace
     * eachother when added to an entity.
     */
    public var name (get, null) :String;

    /**
     * Called after this component has been added to an entity.
     */
    public function onAdded ()
    {
    }

    /**
     * Called just before this component has been removed from its entity.
     */
    public function onRemoved ()
    {
    }

    /**
     * Called when this component receives a game update.
     * @param dt The time elapsed since the last frame, in seconds.
     */
    public function onUpdate (dt :Float)
    {
    }

    /**
     * Removes this component from its owning entity.
     */
    public function dispose ()
    {
        if (owner != null) {
            owner.remove(this);
        }
    }

    private function get_name () :String
    {
        return null; // Subclasses will automagically implement this
    }

    @:allow(flambe) function init (owner :Entity, next :Component)
    {
        this.owner = owner;
        this.next = next;
    }

    @:allow(flambe) inline function setNext (next :Component)
    {
        this.next = next;
    }
}
