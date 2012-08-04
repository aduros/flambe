//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.input.PointerEvent;

class TouchPoint
{
    public var id (default, null) :Int;

    public var viewX (default, null) :Float;
    public var viewY (default, null) :Float;

    /** @private */ public function new (id :Int)
    {
        this.id = id;
        _internal_source = Touch(this);
    }

    /** @private */ public function _internal_init (viewX :Float, viewY :Float)
    {
        this.viewX = viewX;
        this.viewY = viewY;
    }

    // Cached to avoid lots of allocation
    /** @private */ public var _internal_source :EventSource;
}
