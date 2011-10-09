//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

enum AssetType
{
    Image;
    Data;
}

class AssetEntry
{
    public var name (default, null) :String;
    public var url (default, null) :String;
    public var type (default, null) :AssetType;
    public var bytes (default, null) :Int;

    public function new (name, url, type, bytes)
    {
        this.name = name;
        this.url = url;
        this.type = type;
        this.bytes = bytes;
    }
}
