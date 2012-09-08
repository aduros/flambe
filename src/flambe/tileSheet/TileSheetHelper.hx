package flambe.tileSheet;


import flash.display.BitmapData;
import haxe.Json;
class TileSheetHelper {


    public function new ():Void{

    }
    public function prepareAnimTexture(src:String):AnimTextureSheet {
        var seqRaw:Dynamic = Json.parse(pack.loadFile(src));

        var animData:Array<SheetFormat> = new Array<SheetFormat>();
        populateFrameArray(animData, seqRaw.frames);

        animData.sortOn("id");

        var tileSheet:AnimTextureSheet = new AnimTextureSheet();
        tileSheet.init(animData);
        return tileSheet;
    }

    function populateFrameArray(arDest:Array<SheetFormat>, src:Dynamic):Void {
        var entry:SheetFormat;
        var nameId:String;
        var item:SheetFormat;
        for (keyName in Reflect.fields(src)) {
            nameId = keyName.substring(0, keyName.lastIndexOf(".png"));
            entry = Reflect.field(src, keyName);
            item = entry.frame;
            item.id = nameId;
            item.offX = 0;
            item.offY = 0;
            if (entry.trimmed) {
                item.offX = entry.spriteSourceSize.x;
                item.offY = entry.spriteSourceSize.y;
            }
            arDest.push(item);
        }

    }


    public function new() {
    }
}

