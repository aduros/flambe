package flambe.platform.flash;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLRequest;

import haxe.io.Bytes;
import haxe.io.BytesInput;

import flambe.asset.AssetPack;
import flambe.asset.AssetPackLoader;
import flambe.asset.CachingAssetPack;
import flambe.util.Signal0;
import flambe.util.Signal1;

class FlashAssetPackLoader
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

    public function start () :Void
    {
        cancel();

        _loaderInfo = if (url == "bootstrap") {
            // The pack is embedded in the main swf
            Lib.current.loaderInfo;
        } else {
            // The pack will be loaded over HTTP
            new Loader().contentLoaderInfo;
        }

        var self = this;
        _loaderInfo.addEventListener(Event.COMPLETE, onComplete);
        _loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

        if (_loaderInfo.loader != null) {
            _loaderInfo.loader.load(new URLRequest(this.url + ".swf"));
        }
    }

    public function cancel ()
    {
        if (_loaderInfo != null) {
            /*_loaderInfo.loader.close();*/
            _loaderInfo = null;
            bytesLoaded = 0;
            bytesTotal = 0;
        }
    }

    private function onComplete (_)
    {
        freeListeners();
        pack = new CachingAssetPack(new FlashAssetPack(_loaderInfo));
        success.emit();
    }

    private function onProgress (event)
    {
        bytesLoaded = event.bytesLoaded;
        bytesTotal = event.bytesTotal;
        progress.emit();
    }

    private function onError (event :ErrorEvent)
    {
        freeListeners();
        error.emit(event.text);
    }

    private function freeListeners ()
    {
        _loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
        _loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        _loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        _loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
    }

    private var _loaderInfo :LoaderInfo;
}
