//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

interface Pointer
{
    /**
     * True if the environment has a pointing device.
     */
    var supported (isSupported, null) :Bool;

    var down (default, null) :Signal1<PointerEvent>;
    var move (default, null) :Signal1<PointerEvent>;
    var up (default, null) :Signal1<PointerEvent>;

    var x (getX, null) :Float;
    var y (getY, null) :Float;

    function isDown () :Bool;
}
