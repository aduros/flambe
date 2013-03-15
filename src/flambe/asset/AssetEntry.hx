//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

using flambe.util.Strings;

enum AssetType
{
    Image;
    Audio;
    Data;
}

/**
 * Defines an asset that will be loaded.
 */
class AssetEntry
{
    /**
     * The name of this asset.
     */
    public var name (default, null) :String;

    /**
     * The URL or file path this asset will be loaded from. May be appended to
     * Manifest.relativeBasePath or externalBasePath to get the actual URL to load from.
     */
    public var url (default, null) :String;

    /**
     * This asset's content type.
     */
    public var type (default, null) :AssetType;

    /**
     * The size of this asset in bytes, or 0 if unknown.
     */
    public var bytes (default, null) :Int;

    public function new (name :String, url :String, type :AssetType, bytes :Int)
    {
        this.name = name;
        this.url = url;
        this.type = type;
        this.bytes = bytes;
    }

    public function getUrlExtension () :String
    {
        return url.split("?")[0].getFileExtension().toLowerCase();
    }
    
    @:keep
    function hxSerialize (s :haxe.Serializer) 
    {
        s.serialize(name);
        s.serialize(url);
        s.serialize(type);
        s.serialize(bytes);
    }
    
    @:keep
    public function hxUnserialize (s :haxe.Unserializer) 
    {
        this.name = s.unserialize();
        this.url = s.unserialize();
        this.type = s.unserialize();
        this.bytes = s.unserialize();
    }
}
