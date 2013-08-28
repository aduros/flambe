//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;
import flambe.util.Signal0;

/**
 * Optional, extra functionality for scene entities that are added to a Director.
 */
class Scene extends Component
{
    /** Emitted by the Director when this scene becomes the top scene. */
    public var shown (default, null) :Signal0;

    /** Emitted by the Director when this scene is no longer the top scene. */
    public var hidden (default, null) :Signal0;

    /**
     * When true, hints that scenes below this one don't need to be rendered. Scenes that don't fill
     * the entire stage or have a transparent background should set this to false.
     */
    public var opaque (default, null) :Bool;

    public function new (opaque :Bool = true)
    {
        this.opaque = opaque;
        shown = new Signal0();
        hidden = new Signal0();
    }
}
