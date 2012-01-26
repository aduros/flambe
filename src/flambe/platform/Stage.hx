//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.util.Signal0;

interface Stage
{
    var width (getWidth, null) :Int;
    var height (getHeight, null) :Int;

    var resize (default, null) :Signal0;

    function lockOrientation (orient :Orientation) :Void;
}
