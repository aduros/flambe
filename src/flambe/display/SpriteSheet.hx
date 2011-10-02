//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import hxjson2.JSONDecoder;

import flambe.asset.AssetPack;
import flambe.display.Texture;
import flambe.math.FMath;

class SpriteSheet
{
    public var name (default, null) :String;
    public var texture (default, null) :Texture;

    public function new (pack :AssetPack, name :String)
    {
        this.name = name;

        // Spriteloq only ever outputs one PNG
        this.texture = pack.loadTexture(name + ".png");

        _animations = new Hash();

        var json = new JSONDecoder(pack.loadFile(name + ".json"), true).getValue();
        var animations :Array<Dynamic> = json.animations;
        for (animData in animations) {
            var anim = new Animation();
            anim.name = animData.name;
            anim.anchorX = -FMath.toInt(animData.bounds[0]);
            anim.anchorY = -FMath.toInt(animData.bounds[1]);
            anim.delay = 1000 / animData.frameRate;
            anim.loop = (animData.loop != 0);
            anim.frames = [];

            var frameData :Array<Int> = animData.frames;
            var ii = 0;
            while (ii < frameData.length) {
                var frame = new Frame();
                frame.x = frameData[ii + 0];
                frame.y = frameData[ii + 1];
                frame.width = frameData[ii + 2];
                frame.height = frameData[ii + 3];
                frame.offsetX = frameData[ii + 4];
                frame.offsetY = frameData[ii + 5];
                anim.frames.push(frame);

                ii += 6;
            }

            _animations.set(anim.name, anim);
        }
    }

    public function getAnimation (name :String) :Animation
    {
        return _animations.get(name);
    }

    private var _animations :Hash<Animation>;
}

class Animation
{
    public var name :String;
    public var anchorX :Int;
    public var anchorY :Int;
    public var delay :Float;
    public var loop :Bool;
    public var frames :Array<Frame>;

    public function new ()
    {
    }
}

class Frame
{
    public var x :Int;
    public var y :Int;
    public var width :Int;
    public var height :Int;

    public var offsetX :Int;
    public var offsetY :Int;

    public function new ()
    {
    }
}
