//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.util.Value;

/**
 * An asset which may have its contents reloaded. This is used by Flambe to live-reload files in the
 * assets directory, in debug builds.
 */
interface Reloadable
{
    /** Incremented when this asset is reloaded. */
    var reloadCount (get, null) :Value<Int>;
}
