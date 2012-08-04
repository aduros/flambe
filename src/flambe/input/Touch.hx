//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

import flambe.util.Signal1;

interface Touch
{
    var supported (isSupported, null) :Bool;

    var maxPoints (getMaxPoints, null) :Int;

    var points (getPoints, null) :Array<TouchPoint>;

    var down (default, null) :Signal1<TouchPoint>;
    var move (default, null) :Signal1<TouchPoint>;
    var up (default, null) :Signal1<TouchPoint>;
}
