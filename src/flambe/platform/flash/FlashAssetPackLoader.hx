//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.system.LoaderContext;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.util.Assert;

import format.tar.Data;

import haxe.io.BytesInput;
import haxe.io.Bytes;

using flambe.util.Strings;
using StringTools;

class FlashAssetPackLoader extends BasicAssetPackLoader
{
    public function new (platform :FlashPlatform, manifest :Manifest)
    {
        super(platform, manifest);
    }

    override private function loadEntry (url :String, entry :AssetEntry)
    {
        var req = new URLRequest(url);

        // The dispatcher to listen for progress, completion and error events
        var dispatcher :IEventDispatcher;

        // The function called to create the asset after its content loads
        var create :Void -> Dynamic;

        switch (entry.format) {
        case JXR, PNG, JPG, GIF:
            var loader = new Loader();
            dispatcher = loader.contentLoaderInfo;
            create = function () {
                var bitmap :Bitmap = cast loader.content;
                var texture = _platform.getRenderer().createTextureFromImage(bitmap.bitmapData);
                bitmap.bitmapData.dispose();
                return texture;
            };

            var ctx = new LoaderContext();
            ctx.checkPolicyFile = true;
            ctx.allowCodeImport = false;
            ctx.imageDecodingPolicy = ON_LOAD;
            loader.load(req, ctx);

        case MP3:
            var sound = new Sound(req);
            dispatcher = sound;
            create = function () return new FlashSound(sound);

        case Data:
            var urlLoader = new URLLoader(req);
            dispatcher = urlLoader;
            create = function () return new BasicFile(urlLoader.data);
			
        case ZIP:
            var urlLoader = new URLLoader(req);
            urlLoader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
            dispatcher = urlLoader;
            var events = new EventGroup();
            events.addDisposingListener(dispatcher, Event.COMPLETE, function (_) {
                var bytes = Bytes.ofData(urlLoader.data);
                var zip = new haxe.zip.Reader(new BytesInput(bytes));
                var entries:List<haxe.zip.Entry> = zip.read();

                for (entry in entries) {					
                    var extension = entry.fileName.getUrlExtension();  
                    if(entry.fileName.charAt(0)=="." || entry.fileName.indexOf("/.")>=0) {
                        extension="";
                    }
                    if(extension=="" || extension==null) {
                        Log.warn("No extension or weird format for zipped entry, ignoring this asset", ["url", entry.fileName]);
                        continue; 
                    }						

                    _assetsRemaining += 1;	
                    promise.total += entry.dataSize;	

                    var format = Manifest.inferFormat(entry.fileName);
                    var name = entry.fileName.removeFileExtension();
                    if(format == Data) { 
                        name = entry.fileName;
                    }					
                    var entryFlambe = manifest.add(name, entry.fileName, entry.dataSize, format);
                    var asset;	
                    var canAdd = false;				
                    switch(format) {
                        case JXR, PNG, JPG, GIF:
                            var loader = new Loader();
                            loader.loadBytes(entry.data.getData());
                            var dispatcher:IEventDispatcher = loader.contentLoaderInfo;
                            var events = new EventGroup();
                            events.addDisposingListener(dispatcher, Event.COMPLETE, function (_) {
                                create = function () {
                                    var bitmap :Bitmap = cast loader.content;
                                    var texture = _platform.getRenderer().createTexture(bitmap.bitmapData);
                                    bitmap.bitmapData.dispose();
                                    return texture;
                                };
                                asset = create();
                                handleLoad(entryFlambe, asset);		
                            });
                        case MP3:
                            var sound = new Sound();
                            sound.loadCompressedDataFromByteArray(entry.data.getData(), entry.dataSize);
                            create = function () return new FlashSound(sound);
                            canAdd = true;
                        case Data:
                            create = function () return new BasicFile(entry.data.toString());
                            canAdd = true;
                        default:
                            Log.warn("Format not supported for zipped entry, ignoring this asset", ["url", entry.fileName]);						
                            continue;
                    }					
		
                    if (canAdd) {
                        asset = create();
                        handleLoad(entryFlambe, asset);						
                    }
                }
            });
            handleLoad(entry, {});
            return;

        case TAR:
            var urlLoader = new URLLoader(req);
            urlLoader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
            dispatcher = urlLoader;
            var events = new EventGroup();
            events.addDisposingListener(dispatcher, Event.COMPLETE, function (_) {
                var bytes = Bytes.ofData(urlLoader.data);
                var tar = new format.tar.Reader(new BytesInput(bytes));
                var entries:List<format.tar.Entry> = tar.read();

                for (entry in entries) {					
                    var extension = entry.fileName.getUrlExtension();  
                    if(entry.fileName.charAt(0)=="." || entry.fileName.indexOf("/.")>=0) {
                        extension="";
                    }
                    if(extension=="" || extension==null) {
                        Log.warn("No extension or weird format for tar entry, ignoring this asset", ["url", entry.fileName]);
                        continue; 
                    }						

                    _assetsRemaining += 1;	
                    promise.total += entry.fileSize;	

                    var format = Manifest.inferFormat(entry.fileName);
                    var name = entry.fileName.removeFileExtension();
                    if(format == Data) { 
                        name = entry.fileName;
                    }					
                    var entryFlambe = manifest.add(name, entry.fileName, entry.fileSize, format);
                    var asset;	
                    var canAdd = false;				
                    switch(format) {
                        case JXR, PNG, JPG, GIF:
                            var loader = new Loader();
                            loader.loadBytes(entry.data.getData());
                            var dispatcher:IEventDispatcher = loader.contentLoaderInfo;
                            var events = new EventGroup();
                            events.addDisposingListener(dispatcher, Event.COMPLETE, function (_) {
                                create = function () {
                                    var bitmap :Bitmap = cast loader.content;
                                    var texture = _platform.getRenderer().createTexture(bitmap.bitmapData);
                                    bitmap.bitmapData.dispose();
                                    return texture;
                                };
                                asset = create();
                                handleLoad(entryFlambe, asset);		
                            });
                        case MP3:
                            var sound = new Sound();
                            sound.loadCompressedDataFromByteArray(entry.data.getData(), entry.fileSize);
                            create = function () return new FlashSound(sound);
                            canAdd = true;
                        case Data:
                            create = function () return new BasicFile(entry.data.toString());
                            canAdd = true;
                        default:
							_assetsRemaining -= 1;
                   			promise.total -= entry.fileSize;
                            Log.warn("Format not supported for tar entry, ignoring this asset", ["url", entry.fileName]);						
                            continue;
                    }					
		
                    if (canAdd) {
                        asset = create();
                        handleLoad(entryFlambe, asset);						
                    }
                }
            });
            handleLoad(entry, {});
            return;

        default:
            // Should never happen
            Assert.fail("Unsupported format", ["format", entry.format]);
            return;
        }

        var events = new EventGroup();
        events.addListener(dispatcher, ProgressEvent.PROGRESS, function (event :ProgressEvent) {
            handleProgress(entry, cast event.bytesLoaded);
        });
        events.addDisposingListener(dispatcher, Event.COMPLETE, function (_) {
            var asset;
            try {
                asset = create();
            } catch (error :Error) {
                handleError(entry, error.message);
                return;
            }
            if (asset != null) {
                handleLoad(entry, asset);
            } else {
                // Assume this is a failed createTexture()
                handleTextureError(entry);
            }
        });

        var onError = function (event :ErrorEvent) {
            handleError(entry, event.text);
        };
        events.addDisposingListener(dispatcher, IOErrorEvent.IO_ERROR, onError);
        events.addDisposingListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, onError);
    }

    override private function getAssetFormats (fn :Array<AssetFormat> -> Void)
    {
        fn([JXR, PNG, JPG, GIF, MP3, Data, ZIP, TAR]);
    }
}
