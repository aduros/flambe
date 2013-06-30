//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.Reloadable;
import flambe.util.Assert;
import flambe.util.Value;

class BasicReloadable<A>
    implements Reloadable
{
    public var reloadCount (get, null) :Value<Int>;

    public function emitReload ()
    {
        if (_reloadCount != null) {
            ++_reloadCount._;
        }
    }

    public function copyFrom (asset :A)
    {
        Assert.fail(); // See subclasses
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
