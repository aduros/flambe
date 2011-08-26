//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Dom;
import js.Lib;

import haxe.Http;

import flambe.asset.AssetPack;
import flambe.asset.AssetPackLoader;
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
        switch (file.type) {
            case Image:
                var image :Image = untyped __js__ ("new Image()");
                // TODO(bruno): Uncomment this if content hashing is ever added
                // image.validate = "never";
                image.onload = function (_) {
                    var texture = new HtmlTexture();
                    if (CANVAS_TEXTURES) {
                        var canvas :Dynamic = Lib.document.createElement("canvas");
                        canvas.width = image.width;
                        canvas.height = image.height;
                        canvas.getContext("2d").drawImage(image, 0, 0);
                        image = null; // Free it up
                        texture.image = canvas;
                    } else {
                        texture.image = image;
                    }
                    handleLoad(file, texture);
                };
                image.onerror = function (_) {
                    handleError(file);
                };
                image.src = file.url;

            case Data:
                var http = new Http(file.url);
                http.onData = function (data) {
                    handleLoad(file, data);
                };
                http.onError = function (details) {
                    handleError(file, details);
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
        // On iOS < 5, canvas textures are way faster
        // http://jsperf.com/drawimage-vs-canvaspattern/5
        var pattern = ~/(iPhone|iPod|iPad).*OS (\d+)/;
        if (pattern.match(Lib.window.navigator.userAgent)) {
            var version = Std.parseInt(pattern.matched(2));
            CANVAS_TEXTURES = (version < 5);
        } else {
            CANVAS_TEXTURES = false;
        }

        // Populate the manifest hash with the files in /res using macro magic
        var manifest = new Manifest();
        flambe.macro.ManifestBuilder.populateManifest(manifest);
        return manifest;
    }

    /** If true, blit loaded images to a canvas and use that as the texture. */
    private static var CANVAS_TEXTURES :Bool;

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
