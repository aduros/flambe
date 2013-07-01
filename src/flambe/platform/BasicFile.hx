//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.File;

class BasicFile extends InternalReloadable<BasicFile>
    implements File
{
    public function new (content :String)
    {
        _content = content;
    }

    public function toString ()
    {
        return _content;
    }

    override private function copyFrom (that :BasicFile)
    {
        this._content = that._content;
    }

    private var _content :String;
}
