package flambe.tileSheet;

import flambe.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

// =============================  Created by: Amos Laber, Dec 2, 2011
//
// AnimSprite is a class to diplay an animated sprite sheet
// it is initialized with a sprite sheet and can hold multiple
// animation sequnces that can be switched anytime
//
class AnimSprite extends Sprite {
    public var tileSheet(getTileSheet, never):AnimTextureSheet;
    public var numFrames(getNumFrames, never):Int;
    public var numSequences(getNumSequences, never):Int;
    public var seqFrame(getSeqFrame, never):UInt;
    public var frame(getFrame, setFrame):UInt;

    var mAnimSheet:AnimTextureSheet;
    var mSequences:Array<AnimSeqData>;
    var curAnim:AnimSeqData;
// current sequence
    var dirty:Bool;
    var donePlaying:Bool;
    var curIndex:UInt;
// Frame index into tile sheet
    var curFrame:UInt;
// Frame index in a sequence (local)
// Internal, used to time each frame of animation.
    var frameTimer:Float;
    static public inline var LEFT:UInt = 1;
    static public inline var RIGHT:UInt = 2;

    public function new() {

        super();
        fakeElapsed = 0.0167;
      //  super(bitmapData);
        frameTimer = 0;
        mSequences = [];
    }

//
// Initialize the sprite with the texture sheet.
//  supportFlip: set to true if you intend to use right/left flipping
//

    public function initialize(sheet:AnimTextureSheet):Void {
        if (sheet == null)
            return;
        mAnimSheet = sheet;
// Create the frame buffer
        bitmapData = new BitmapData(mAnimSheet.maxRect.width, mAnimSheet.maxRect.height);
       // smoothing = true;
        curAnim = null;
        this.frame = 0;
        drawFrame(true);
    }



// Check if we are playing a sequence
//

    public function isPlaying(index:Int = 0):Bool {
        return !donePlaying;
    }

    public function getTileSheet():AnimTextureSheet {
        return mAnimSheet;
    }

    public function getNumFrames():Int {
        return mAnimSheet.numFrames;
    }

    public function getNumSequences():Int {
        return mSequences.length;
    }

    public function getSeqFrame():UInt {
        return curFrame;
    }

    public function getFrame():UInt {
        return curIndex;
    }

    public function setFrame(val:UInt):UInt {
        curFrame = val;
        if (curAnim != null)
            curIndex = curAnim.arFrames[curFrame]
        else curIndex = val;
//curAnim = null;
        dirty = true;
        return val;
    }

    public function getSequenceData(seq:Int):AnimSeqData {
        return mSequences[seq];
    }

    public function getSequence(seq:Int):String {
        return mSequences[seq].seqName;
    }

    public function addSequence(name:String, frames:Array<SheetFormat>, ?frameRate:Float = 0, ?looped:Bool = true):Void {
        mSequences.push(new AnimSeqData(name, frames, frameRate, looped));
    }

    public function findSequence(name:String):AnimSeqData {
        return findSequenceByName(name);
    }

    function findSequenceByName(name:String):AnimSeqData {
        var aSeq:AnimSeqData;
        var i:Int = 0;
        while (i < mSequences.length) {
            aSeq = cast((mSequences[i]), AnimSeqData);
            if (aSeq.seqName == name) {
                return aSeq;
            }
            i++;
        }
        return null;
    }

// Start playing a sequence
//

    public function play(name:String = null):Void {
// Continue playing from last frame
        if (name == null) {
            donePlaying = false;
            dirty = true;
            frameTimer = 0;
            return;
        }
        ;
        curFrame = 0;
        curIndex = 0;
        frameTimer = 0;
        curAnim = findSequenceByName(name);
        if (curAnim == null) {
            trace("play: cannot find sequence: " + name);
            return;
        }
// trace("playing " + name +", frames: " + curAnim.arFrames.length);
// Set to first frame
        curIndex = curAnim.arFrames[0];
        donePlaying = false;
        dirty = true;
// Stop if we only have a single frame
        if (curAnim.arFrames.length == 1)
            donePlaying = true;
    }

// External use only (editor)
//

    public function stop():Void {
        donePlaying = true;
    }

// Manually advance one frame forwards or back
// Used by the viewer (not the game)
//

    public function frameAdvance(next:Bool):Void {
        if (next) {
            if (curFrame < curAnim.arFrames.length - 1)
                ++curFrame;
        }

        else {
            if (curFrame > 0)
                --curFrame;
        }

        curIndex = curAnim.arFrames[curFrame];
        dirty = true;
    }

    public function drawFrame(force:Bool = false):Void {
        if (force || dirty)
            drawFrameInternal();
    }

// TODO: Replace with global time based on getTimer()
    var fakeElapsed:Float;
//  Call this function on every frame update
//

    public function updateAnimation():Void {
        if (curAnim != null && curAnim.delay > 0 && !donePlaying) {
// Check elapsed time and adjust to sequence rate
            frameTimer += fakeElapsed;
            while (frameTimer > curAnim.delay) {
                frameTimer = frameTimer - curAnim.delay;
                advanceFrame();
            }

        }
        if (dirty)
            drawFrameInternal();
    }

//
//

    function advanceFrame():Void {
        if (curFrame == curAnim.arFrames.length - 1) {
            if (curAnim.loop)
                curFrame = 0
            else donePlaying = true;
        }

        else ++curFrame;
        curIndex = curAnim.arFrames[curFrame];
        dirty = true;
    }

// Internal function to update the current animation frame

    function drawFrameInternal():Void {
        dirty = false;
        bitmapData.fillRect(bitmapData.rect, 0);
        mAnimSheet.drawFrame(curIndex, bitmapData);
    }

}

