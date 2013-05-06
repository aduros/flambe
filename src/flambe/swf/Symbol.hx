//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;

/**
 * Defines an exported SWF symbol.
 */
interface Symbol
{
    /**
     * The name of this symbol.
     */
    var name (get, null) :String;

    /**
     * Instantiate a sprite that displays this symbol.
     */
    function createSprite () :Sprite;
}
