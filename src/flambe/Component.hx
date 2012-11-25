//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Disposable;

/**
 * Components are bits of data and logic that can be added to entities.
 */
#if !macro
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

    public function getName () :String
    {
        return null; // Subclasses will automagically implement this
    }

    /**
     * Called after this component has been added to an entity.
     */
    public function onAdded ()
    {
    }

    /**
     * Called before this component has been removed from an entity.
     */
    public function onRemoved ()
    {
    }

    /**
     * Called when this component has been disposed.
     */
    public function onDispose ()
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
     * Removes this component from its owning entity and calls onDispose.
     */
    public function dispose ()
    {
        if (owner != null) {
            owner.remove(this);
        }
        onDispose();
    }

    /** @private */ public function _internal_init (owner :Entity, next :Component)
    {
        this.owner = owner;
        this.next = next;
    }

    /** @private */ inline public function _internal_setNext (next :Component)
    {
        this.next = next;
    }
}
