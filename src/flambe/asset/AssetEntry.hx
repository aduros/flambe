//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.asset;

using flambe.util.Strings;

/** Specifies all supported asset formats across all Flambe platforms. */
enum AssetFormat
{
    // Images
    WEBP; JXR; PNG; JPG; GIF;

    // Compressed textures
    DDS; PVR; PKM;

    // Audio
    MP3; M4A; OPUS; OGG; WAV;

    // Raw text/data
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
     * The URL or file path this asset will be loaded from. Will be appended to `Manifest.localBase`
     * or `Manifest.remoteBase` to get the actual URL to load from.
     */
    public var url (default, null) :String;

    /**
     * The format this asset will be loaded as.
     */
    public var format (default, null) :AssetFormat;

    /**
     * The size of this asset in bytes, or 0 if unknown.
     */
    public var bytes (default, null) :Int;

    public function new (name :String, url :String, format :AssetFormat, bytes :Int)
    {
        this.name = name;
        this.url = url;
        this.format = format;
        this.bytes = bytes;
    }
}
