//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

/**
 * A loaded file containing raw data.
 */
interface File extends Asset
{
    /** Return the contents of this file as a string. */
    function toString () :String;
}
