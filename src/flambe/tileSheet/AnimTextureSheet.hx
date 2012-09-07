package flambe.tileSheet;

import flash.Vector;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

//
// AnimPack holds a single texture tile sheet, and can have
// multiple animation sequneces in it.
//
class AnimTextureSheet {
    public var name(getName, never):String;
    public var maxRect(getMaxRect, never):Rectangle;
    public var numFrames(getNumFrames, never):Int;

    var mName:String;
    var mTextureRegions:Vector<Rectangle>;
    var mFrameOffsets:Vector<Point>;
    var mTextureSheet:BitmapData;
    var mFrameRect:Rectangle;

    public function new() {
;
        mTextureRegions = new Vector<Rectangle>();
        mFrameRect = new Rectangle();
        mFrameOffsets = new Vector<Point>();
    }

    public function getName():String {
        return mName;
    }

    public function getMaxRect():Rectangle {
        return mFrameRect;
    }

    public function getNumFrames():Int {
        return mTextureRegions.length;
    }

    public function getFrameWidth(fr:Int):Float {
        return (mTextureRegions[fr].width + mFrameOffsets[fr].x);
    }

    public function getFrameHeight(fr:Int):Float {
        return (mTextureRegions[fr].height + mFrameOffsets[fr].y);
    }

    public function init(sheet:BitmapData, arFrameData:Array<SheetFormat>):Void {
        mTextureSheet = sheet;
        var rcFrame:Rectangle;
        var regPt:Point;
        var i:Int = 0;
        while (i < arFrameData.length) {
            rcFrame = new Rectangle();
            rcFrame.x = arFrameData[i].x;
            rcFrame.y = arFrameData[i].y;
            rcFrame.width = arFrameData[i].w;
            rcFrame.height = arFrameData[i].h;
            mTextureRegions.push(rcFrame);
            regPt = new Point();
            regPt.x = arFrameData[i].offX;
            regPt.y = arFrameData[i].offY;
            mFrameOffsets.push(regPt);
            mFrameRect.width = Math.max(mFrameRect.width, rcFrame.width + regPt.x);
            mFrameRect.height = Math.max(mFrameRect.height, rcFrame.height + regPt.y);
            i++;
        }
    }

    public function drawFrame(frame:Int, destBmp:BitmapData):Void {
        destBmp.copyPixels(mTextureSheet, mTextureRegions[frame], mFrameOffsets[frame]);
    }

}

