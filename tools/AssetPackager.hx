import neko.FileSystem;
import neko.io.File;
import neko.Sys;
import neko.Lib;

import haxe.io.BytesOutput;
import haxe.io.Output;

import format.abc.Data;
import format.swf.Data;
import format.swf.Writer;

using StringTools;
using Lambda;

class PackSwfWriter
{
    public function new (out :Output)
    {
        _swf = new Writer(out);
    }

    public function write (packDir :String, files :Iterable<String>)
    {
        _id = 0;
        _swf.writeHeader({
            version: 10,
            compressed: true,
            width: 640,
            height: 480,
            fps: 30.0,
            nframes: 1
        });
        _swf.writeTag(TSandBox(8)); // AS3
        for (file in files) {
            var bytes = File.read(packDir + "/" + file, true).readAll();
            var lower = file.toLowerCase();
            var baseClass = if (lower.endsWith(".png")) {
                writePng(bytes);
            } else if (lower.endsWith(".mp3")) {
                writeMp3(bytes);
            } else {
                writeByteArray(bytes);
            }
            writeClass(file.replace(".", "$"), baseClass);
        }
        _swf.writeTag(TShowFrame);
        _swf.writeEnd();
    }

    private function writePng (bytes)
    {
        _swf.writeTag(TBitsJPEG2(++_id, bytes));
        return "flash.display.BitmapData";
    }

    private function writeMp3 (bytes)
    {
        return null; // TODO
    }

    private function writeByteArray (bytes)
    {
        return null; // TODO
    }

    private function writeClass (className, baseClass)
    {
        var ctx = new format.abc.Context();
        var c = ctx.beginClass(className);
        c.superclass = ctx.type(baseClass);
        var f = ctx.beginConstructor([]);
        f.maxStack = 3;
        f.maxScope = 1;
        ctx.ops([OThis,OScope,OThis,OInt(0),OInt(0),OConstructSuper(2),ORetVoid]);
        ctx.finalize();

        var abcBytes = new BytesOutput();
        var abcWriter = new format.abc.Writer(abcBytes);
        abcWriter.write(ctx.getData());

        _swf.writeTag(TActionScript3(abcBytes.getBytes(), {id: _id, label: className}));
        _swf.writeTag(TSymbolClass([{cid: _id, className: className}]));
    }

    private var _swf :Writer;
    private var _id :Int;
}

class AssetPackager
{
    public static function readRecursive (root, dir = ".")
    {
        var result = [];
        for (file in readDirectoryNoHidden(root + "/" + dir)) {
            var fullPath = root + "/" + dir + "/" + file;
            var relPath = if (dir == ".") file else dir + "/" + file;
            if (FileSystem.isDirectory(fullPath)) {
                result = result.concat(readRecursive(root, relPath));
            } else {
                result.push(relPath);
            }
        }
        return result;
    }

    public static function readDirectoryNoHidden (dir)
    {
        return FileSystem.readDirectory(dir).filter(function (file) return file.charAt(0) != ".");
    }

    public static function main ()
    {
        var argv = Sys.args();
        if (argv.length < 2) {
            Lib.println("Usage: packager.n ASSETDIR DISTDIR");
            return;
        }

        var assetDir = FileSystem.fullPath(argv[0]);
        var outDir = FileSystem.fullPath(argv[1]);
        Sys.setCwd(assetDir);

        for (packName in readDirectoryNoHidden(assetDir).filter(FileSystem.isDirectory)) {
            var swf = new PackSwfWriter(File.write(outDir + "/" + packName + ".swf", true));
            swf.write(assetDir + "/" + packName, readRecursive(assetDir + "/" + packName));
        }
    }
}
