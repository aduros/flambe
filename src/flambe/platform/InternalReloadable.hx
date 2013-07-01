//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.BasicReloadable;
import flambe.util.Assert;

class InternalReloadable<A> extends BasicReloadable
{
    public function reload (asset :A)
    {
        copyFrom(asset);
        emitReload();
    }

    private function copyFrom (asset :A)
    {
        Assert.fail(); // See subclasses
    }
}
