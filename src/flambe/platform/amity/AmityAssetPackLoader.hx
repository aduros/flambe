package flambe.platform.amity;

import flambe.asset.AssetPack;
import flambe.asset.AssetPackLoader;
import flambe.asset.CachingAssetPack;
import flambe.util.Signal0;
import flambe.util.Signal1;

class AmityAssetPackLoader
    implements AssetPackLoader
{
    public var url (default, null) :String;
    public var bytesLoaded (default, null) :Int;
    public var bytesTotal (default, null) :Int;
    public var pack (default, null) :AssetPack;

    public var progress (default, null) :Signal0;
    public var success (default, null) :Signal0;
    public var error (default, null) :Signal1<String>;

    public function new (url :String)
    {
        this.url = url;
        this.progress = new Signal0();
        this.success = new Signal0();
        this.error = new Signal1();
    }

    public function start ()
    {
        pack = new CachingAssetPack(new AmityAssetPack(url));
        success.emit();
    }

    public function cancel ()
    {
        trace("STUB");
    }
}
