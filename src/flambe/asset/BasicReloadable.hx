//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.util.Value;

/**
 * A handy implementation of Reloadable, designed to be subclassed.
 */
class BasicReloadable
    implements Reloadable
{
    public var reloadCount (get, null) :Value<Int>;

    private function emitReload ()
    {
        if (_reloadCount != null) {
            ++_reloadCount._;
        }
    }

    private function get_reloadCount () :Value<Int>
    {
        if (_reloadCount == null) {
            _reloadCount = new Value<Int>(0);
        }
        return _reloadCount;
    }

    private var _reloadCount :Value<Int>;
}
