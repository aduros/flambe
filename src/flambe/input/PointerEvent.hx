//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

class PointerEvent
{
    /**
     * The X position of the pointing device, in view (stage) coordinates.
     */
    public var viewX (default, null) :Float;

    /**
     * The Y position of the pointing device, in view (stage) coordinates.
     */
    public var viewY (default, null) :Float;

    public function new (viewX :Float, viewY :Float)
    {
        this.viewX = viewX;
        this.viewY = viewY;
    }
}
