//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.File;

class BasicFile extends BasicAsset<BasicFile>
    implements File
{
    public function new (content :String)
    {
        super();
        _content = content;
    }

    public function toString ()
    {
        assertNotDisposed();

        return _content;
    }

    override private function copyFrom (that :BasicFile)
    {
        this._content = that._content;
    }

    override private function onDisposed ()
    {
        _content = null;
    }

    private var _content :String;
}
