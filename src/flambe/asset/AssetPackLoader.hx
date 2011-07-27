//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

import flambe.util.Signal0;
import flambe.util.Signal1;

interface AssetPackLoader
{
    public var url (default, null) :String;
    public var bytesLoaded (default, null) :Int;
    public var bytesTotal (default, null) :Int;
    public var pack (default, null) :AssetPack;

    public var progress (default, null) :Signal0;
    public var success (default, null) :Signal0;
    public var error (default, null) :Signal1<String>;

    public function start () :Void;
    public function cancel () :Void;
}
