package flambe.tileSheet;


import flambe.Component;
import flash.display.BitmapData;
import haxe.Json;
class TileSheetHelper extends Component {


    public function new ():Void{
        super();

    }
    public function prepareAnimTexture(src:String):AnimTextureSheet {
        var seqRaw:Dynamic = Json.parse(pack.loadFile(src));

        var animData:Array<FrameData> = new Array<FrameData>();
        populateFrameArray(animData, seqRaw.frames);

        animData.sortOn("id");

        var tileSheet:AnimTextureSheet = new AnimTextureSheet();
        tileSheet.init(animData);
        return tileSheet;
    }

    function populateFrameArray(arDest:Array<FrameData>, src:Dynamic):Void {
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



}

