//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

/**
 * Represents a unit of execution that is called over time.
 */
interface Action
{
    /**
     * Called when the owning entity has been updated.
     * @param dt The time elapsed since the last frame, in seconds.
     * @param actor The entity of the Script that this action was added to.
     * @return True if the action is complete and no longer wants to receive updates.
     */
    function update (dt :Float, actor :Entity) :Bool;
}
