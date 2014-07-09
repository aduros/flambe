//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flambe.display.Texture;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.util.Assert;

class FlashEmbeddedAssetPackLoader extends BasicAssetPackLoader
{
    public function new (platform :FlashPlatform, manifest :Manifest)
    {
        super(platform, manifest);
    }

    override private function loadEntry (url :String, entry :AssetEntry)
    {
        var asset : Dynamic;
        // create a valid AS3 class name from the asset url, replace all non digits, non word characters, and leading non-letters with dollar signs
        var className = ~/[^\d|\w|\$]|^[^A-za-z]/g.replace(url.substring(url.indexOf("/") + 1, url.lastIndexOf(".")), "$");

        if (Type.resolveClass(className) != null) {
            var resInst = Type.createInstance(Type.resolveClass(className), []); // an instance of the resource

            switch (entry.format) {
                case JXR, PNG, JPG, GIF:
                        asset = _platform.getRenderer().createTextureFromImage(resInst.bitmapData);
                        resInst.bitmapData.dispose();

                case MP3:
                    var sound :Sound = cast resInst;
                    asset = new FlashSound(sound);

                case Data:
                    var data :ByteArray = cast resInst;
                    asset =  new BasicFile(data.toString());

                default:
                    // Should never happen
                    Assert.fail("Unsupported format", ["format", entry.format]);
                    return;
            }

            if (asset != null) {
                handleLoad(entry, asset);
            } else {
                // Assume this is a failed createTexture()
                trace("failed to create texture...");
                handleTextureError(entry);
            }
        }
    }

    override private function getAssetFormats (fn :Array<AssetFormat> -> Void)
    {
        fn([JXR, PNG, JPG, GIF, MP3, Data]);
    }
}
