//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

/**
 * An object that exists outside of the entity hierarchy, but still needs to be updated each frame.
 * This is an implementation detail, nothing outside of flambe.platform should implement this.
 */
interface Tickable
{
    /**
     * @param dt The elapsed delta-time in seconds.
     * @returns True if this Tickable should no longer be updated.
     */
    function update (dt :Float) :Bool;
}
