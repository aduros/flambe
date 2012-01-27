//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

class PointerEvent
{
    public var viewX (default, null) :Float;
    public var viewY (default, null) :Float;

    public function new (viewX :Float, viewY :Float)
    {
        this.viewX = viewX;
        this.viewY = viewY;
    }
}
