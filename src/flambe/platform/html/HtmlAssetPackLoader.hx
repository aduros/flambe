//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Dom;

import haxe.Http;

import flambe.asset.AssetPack;
import flambe.asset.AssetPackLoader;
import flambe.asset.CachingAssetPack;
import flambe.util.Signal0;
import flambe.util.Signal1;

class HtmlAssetPackLoader
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

        bytesLoaded = 0;
        bytesTotal = 0;

        var files = MANIFEST.get(url);
        if (files == null) {
            error.emit("Unrecognized pack: " + url);
            return;
        }

        for (file in files) {
            bytesTotal += file.bytes;
            loadFile(file);
        }
    }

    public function cancel ()
    {
        // TODO: Actually stop loading everything
        _contents = new Hash();
    }

    private function loadFile (file :FileEntry)
    {
        var self = this;
        switch (file.type) {
            case Image:
                var image :Image = untyped __js__ ("new Image()");
                image.onload = function (_) {
                    self.handleLoad(file, image);
                };
                image.onerror = function (_) {
                    self.handleError(file);
                };
                image.src = file.url;

            case Data:
                var http = new Http(file.url);
                http.onData = function (data) {
                    self.handleLoad(file, data);
                };
                http.onError = function (details) {
                    self.handleError(file, details);
                };
                http.request(false);
        }
    }

    private function handleLoad (file :FileEntry, data :Dynamic)
    {
        _contents.set(file.name, data);

        bytesLoaded += file.bytes;
        progress.emit();

        if (bytesLoaded == bytesTotal) {
            pack = new HtmlAssetPack(_contents);
            success.emit();
        }
    }

    private function handleError (file :FileEntry, ?details :String)
    {
        var text = "Error loading " + file.url;
        if (details != null) {
            text += ": " + details;
        }
        error.emit(text);
    }

    private static function createManifest ()
    {
        var manifest = new Manifest();
        flambe.macro.ManifestBuilder.populateManifest(manifest);
        return manifest;
    }

    private static var MANIFEST = createManifest();

    private var _contents :Hash<Dynamic>;
}

enum FileType
{
    Image;
    Data;
}

private typedef FileEntry = {
    var name :String;
    var url :String;
    var type :FileType;
    var bytes :Int;
};

private typedef Manifest = Hash<Array<FileEntry>>;
