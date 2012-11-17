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

class FlashAssetPackLoader extends BasicAssetPackLoader
{
    public function new (platform :FlashPlatform, manifest :Manifest)
    {
        super(platform, manifest);
    }

    override private function loadEntry (entry :AssetEntry)
    {
        var req = new URLRequest(entry.url);

        // The dispatcher to listen for progress, completion and error events
        var dispatcher :IEventDispatcher;

        // The function called to create the asset after its content loads
        var create :Void -> Dynamic;

        try switch (entry.type) {
            case Image:
                var loader = new Loader();
                dispatcher = loader.contentLoaderInfo;
                create = function () {
                    var bitmap :Bitmap = cast loader.content;
                    return _platform.getRenderer().createTexture(bitmap.bitmapData);
                };

                var ctx = new LoaderContext();
                ctx.checkPolicyFile = true;
                ctx.allowCodeImport = false;
                loader.load(req, ctx);

            case Audio:
                var sound = new Sound(req);
                dispatcher = sound;
                create = function () return new FlashSound(sound);

            case Data:
                var urlLoader = new URLLoader(req);
                dispatcher = urlLoader;
                create = function () return urlLoader.data;

        } catch (error :Error) {
            handleError(error.message);
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
                handleError(error.message);
                return;
            }
            handleLoad(entry, asset);
        });
        events.addDisposingListener(dispatcher, IOErrorEvent.IO_ERROR, onError);
        events.addDisposingListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, onError);
    }

    override private function getAudioFormats () :Array<String>
    {
        // TODO(bruno): Flash actually has an m4a decoder, but it's only accessible through the
        // horrendous NetStream API and not good old flash.media.Sound
        return (Capabilities.hasAudio && Capabilities.hasMP3) ? [ "mp3" ] : [];
    }

    private function onError (event :ErrorEvent)
    {
        handleError(event.text);
    }
}
