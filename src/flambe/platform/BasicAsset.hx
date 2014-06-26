//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.Asset;
import flambe.util.Assert;
import flambe.util.Value;

class BasicAsset<A/*:BasicAsset<A>*/>
    implements Asset
{
    public var reloadCount (get, null) :Value<Int>;

    public function new ()
    {
    }

    inline public function assertNotDisposed ()
    {
        Assert.that(!_disposed, "Asset cannot be used after being disposed");
    }

    @:final public function reload (asset :A)
    {
        dispose();
        _disposed = false;
        copyFrom(asset);
        ++reloadCount._;
    }

    @:final public function dispose ()
    {
        if (!_disposed) {
            _disposed = true;
            onDisposed();
        }
    }

    /** Fully copy the content from another asset type, for reloading. */
    private function copyFrom (asset :A)
    {
        Assert.fail(); // See subclasses
    }

    /** Handle disposing. */
    private function onDisposed ()
    {
        Assert.fail(); // See subclasses
    }

    // Overridden in subclasses!
    private function get_reloadCount () :Value<Int>
    {
        if (_reloadCount == null) {
            _reloadCount = new Value<Int>(0);
        }
        return _reloadCount;
    }

    private var _disposed :Bool = false;
    private var _reloadCount :Value<Int> = null;
}
