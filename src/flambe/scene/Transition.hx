//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

/**
 * A transition between two scenes.
 */
class Transition
{
    /**
     * Called by the Director to start the transition.
     * @param director The director that requested the transition.
     * @param from The old scene being transitioned from.
     * @param to The new scene being transitioned to.
     */
    public function init (director :Director, from :Entity, to :Entity)
    {
        _director = director;
        _from = from;
        _to = to;
    }

    /**
     * Called by the Director to update the transition.
     * @returns True if the transition is complete.
     */
    public function update (dt :Float) :Bool
    {
        // See subclasses
        return true;
    }

    /**
     * Completes the transition. Note that the Director may call this at any time to fast-forward
     * the transition.
     */
    public function complete ()
    {
        // See subclasses
    }

    private var _director :Director;
    private var _from :Entity;
    private var _to :Entity;
}
