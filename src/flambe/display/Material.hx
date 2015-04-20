//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.Component;

/**
 * A Material component defining how an entity should be drawn
 */
class Material extends Component
{
    public var texture :Texture;
    public var effect :String;

    public function new()
    {
        effect = "default";
    }

    // Chainable Utility functions
    public function setEffect(effect :String):Material
    {
        this.effect = effect;
        return this; // Return this for chaining
    }

}
