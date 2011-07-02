//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.display;

import flambe.math.FMath;
import flambe.platform.DrawingContext;

class Animation
{
    public var delay (default, null) :Int;
    public var frames (default, null) :Array<Int>;
    public var looping (default, null) :Bool;

    public function new (delay :Int, frames :Array<Int>)
    {
        this.delay = delay;
        this.frames = frames;
        this.looping = false;
    }

    public function loop () :Animation
    {
        this.looping = true;
        return this;
    }
}

class AnimatedSprite extends Sprite
{
    public var texture (default, null) :Texture;
    public var frame (getFrame, setFrameAndStop) :Int;
    public var animation (default, null) :Animation;

    public function new (texture :Texture, framesWide :Int, framesHigh :Int)
    {
        super();
        this.texture = texture;
        _frameWidth = FMath.toInt(texture.width / framesWide);
        _frameHeight = FMath.toInt(texture.height / framesHigh);
        setFrame(0);
    }

    public function play (anim :Animation)
    {
        if (animation != null && animation.looping) {
            _defaultAnim = animation;
        }
        animation = anim;
        _frame = anim.frames[0];
        _elapsed = 0;
    }

    public function stop ()
    {
        animation = null;
        _defaultAnim = null;
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);

        if (animation != null) {
            _elapsed += dt;
            var frameIdx = FMath.toInt(_elapsed / animation.delay);
            if (frameIdx >= animation.frames.length) {
                if (animation.looping) {
                    frameIdx %= animation.frames.length;
                } else {
                    if (_defaultAnim != null) {
                        play(_defaultAnim);
                    } else {
                        // Stop on the last frame
                        setFrameAndStop(animation.frames[animation.frames.length]);
                    }
                    return;
                }
            }
            setFrame(animation.frames[frameIdx]);
        }
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawSubImage(texture, 0, 0, _frameX, _frameY, _frameWidth, _frameHeight);
    }

    override public function getNaturalWidth () :Float
    {
        return _frameWidth;
    }

    override public function getNaturalHeight () :Float
    {
        return _frameHeight;
    }

    inline private function getFrame () :Int
    {
        return _frame;
    }

    private function setFrameAndStop (frame :Int) :Int
    {
        setFrame(frame);
        stop();
        return frame;
    }

    private function setFrame (frame :Int)
    {
        if (frame == _frame) {
            return;
        }
        var x = frame*_frameWidth;
        _frameX = x % texture.width;
        _frameY = _frameHeight * FMath.toInt(x / texture.width);
        _frame = _frameWidth;
    }

    private var _elapsed :Int;

    private var _frame :Int;
    private var _frameX :Float;
    private var _frameY :Float;

    private var _defaultAnim :Animation;

    private var _frameWidth :Int;
    private var _frameHeight :Int;
}
