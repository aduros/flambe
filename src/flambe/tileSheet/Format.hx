package flambe.tileSheet;


typedef SheetFormat = {
// A checksum of the original FLA library used to generate this file, used by the exporter tool
// to detect modifications
      id:String,
    frame:FrameData,
    rotated:Bool,
    trimmed:Bool,
    spriteSourceSize:FrameData,
    sourceSize:Size
}

typedef FrameData = {
// A checksum of the original FLA library used to generate this file, used by the exporter tool
// to detect modifications
    x:Float,
    y:Float,
    width:Float,
    height:Float,
    offX:Float,
    offY:Float
}

typedef Size = {
    x:Float,
    y:Float
}


