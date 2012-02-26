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
import flambe.platform.BasicAssetPackLoader;

class FlashAssetPackLoader extends BasicAssetPackLoader
{
    public function new (manifest :Manifest)
    {
        super(manifest);
    }

    override private function loadEntry (entry :AssetEntry)
    {
        var dispatcher :IEventDispatcher = null;
        var req = new URLRequest(entry.url);

        switch (entry.type) {
            case Image:
                var loader = new Loader();
                dispatcher = loader.contentLoaderInfo;
                dispatcher.addEventListener(Event.COMPLETE, function (_) {
                    var bitmap :Bitmap = cast loader.content;
                    var texture = new FlashTexture(bitmap.bitmapData);
                    var renderer = FlashAppDriver.instance.renderer;
                    renderer.uploadTexture(texture);
                    handleLoad(entry, texture);
                });
                var ctx = new LoaderContext();
                ctx.checkPolicyFile = true;
                try {
                    loader.load(req, ctx);
                } catch (error :Error) {
                    handleError(error.message);
                }

            case Audio:
                var sound = new Sound(req);
                dispatcher = sound;
                dispatcher.addEventListener(Event.COMPLETE, function (_) {
                    handleLoad(entry, new FlashSound(sound));
                });

            case Data:
                var urlLoader = new URLLoader();
                dispatcher = urlLoader;
                dispatcher.addEventListener(Event.COMPLETE, function (_) {
                    handleLoad(entry, urlLoader.data);
                });
                try {
                    urlLoader.load(req);
                } catch (error :Error) {
                    handleError(error.message);
                }
        }

        dispatcher.addEventListener(Event.COMPLETE, function (_) {
            dispatcher = null;
        });
        dispatcher.addEventListener(ProgressEvent.PROGRESS, function (event :ProgressEvent) {
            handleProgress(entry, cast event.bytesLoaded);
        });
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onError);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
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
