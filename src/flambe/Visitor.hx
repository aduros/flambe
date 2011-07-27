//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.display.Sprite;

interface Visitor
{
    /**
     * Called when the visitor descends into a new entity in the tree.
     * @return False to ignore this entity, pruning it from iteration.
     */
    function enterEntity (entity :Entity) :Bool;

    /**
     * Called to process an entity's component.
     */
    function acceptComponent (comp :Component) :Void;

    /**
     * Called right before the visitor leaves the entity and ascends into its parent.
     */
    function leaveEntity (entity :Entity) :Void;
}
