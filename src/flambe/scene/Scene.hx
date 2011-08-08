//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;
import flambe.util.Signal0;

class Scene extends Component
{
    // Emitted by the Director when this scene becomes the top scene
    public var shown (default, null) :Signal0;

    // Emitted by the Director when this scene is no longer the top scene
    public var hidden (default, null) :Signal0;

    public function new ()
    {
        shown = new Signal0();
        hidden = new Signal0();
    }
}
