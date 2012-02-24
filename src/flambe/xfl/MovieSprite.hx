//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.xfl;

import flambe.display.Sprite;
import flambe.xfl.MovieSymbol;

class MovieSprite extends Sprite
{
    public function new (movie :MovieSymbol)
    {
        super();

        var frames = 0;
        _layers = [];

        for (layer in movie.layers) {
            _layers.push(new LayerSprite(layer));
            frames = cast Math.max(layer.frames, frames);
        }

        _duration = 1000/30 *frames;
        _goingToFrame = false;
        _frame = 0;
        goto(1, true, false);
    }

    override public function onAdded ()
    {
        for (layer in _layers) {
            owner.addChild(new Entity().add(layer));
        }
        _elapsed = 0;
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);

        _elapsed += dt;
        if (_elapsed > _duration) {
            _elapsed = _elapsed % _duration;
        }

        var newFrame = Std.int(_elapsed * 30/1000);
        var overDuration = dt >= _duration;

        // TODO(bruno): Handle _stopFrame?

        goto(newFrame, false, overDuration);
    }

    private function goto (newFrame :Int, fromSkip :Bool, overDuration :Bool)
    {
        if (_goingToFrame) {
            _pendingFrame = newFrame;
            return;
        }
        _goingToFrame = true; // TODO(bruno): Why is this necessary?

        var differentFrame = newFrame != _frame;
        var wrapped = newFrame < _frame;
        if (differentFrame) {
            if (wrapped) {
                for (layer in _layers) {
                    layer.changedKeyframe = true;
                    layer.lastFrame = 0;
                }
            }
            for (layer in _layers) {
                layer.composeFrame(newFrame);
            }
        }

        var oldFrame = _frame;
        _frame = newFrame;

        _goingToFrame = false;
        if (_pendingFrame != -1) {
            newFrame = _pendingFrame;
            _pendingFrame = -1;
            goto(newFrame, true, false);
        }
    }

    private var _lib :Library;

    private var _layers :Array<LayerSprite>;
    private var _duration :Float;
    private var _elapsed :Float;

    private var _frame :Int;
    private var _goingToFrame :Bool;
    private var _pendingFrame :Int;
}

private class LayerSprite extends Sprite
{
    public var changedKeyframe :Bool;
    public var lastFrame :Int;

    public function new (layer :MovieLayer)
    {
        super();
        changedKeyframe = false;
        lastFrame = 0;
        _keyframes = layer.keyframes;
    }

    override public function onAdded ()
    {
        var lastSymbol = null;
        for (kf in _keyframes) {
            if (kf.symbol != null) {
                lastSymbol = kf.symbol;
                break;
            }
        }

        var multipleSymbols = false;
        for (kf in _keyframes) {
            if (kf.symbol != lastSymbol) {
                multipleSymbols = true;
                break;
            }
        }

        if (multipleSymbols) {
            // _displays = [];
            // for (kf in _keyframes) {
            //     var display = new Entity().add(this);
            // }
        } else if (lastSymbol != null) {
            owner.addChild(new Entity().add(lastSymbol.createSprite()));
        }
    }

    public function composeFrame (frame :Int)
    {
        while (lastFrame < _keyframes.length - 1 && _keyframes[lastFrame + 1].index <= frame) {
            ++lastFrame;
            changedKeyframe = true;
        }

        if (changedKeyframe && _displays != null) {
            // owner.replaceChildAt(_layerIdx, _displays[lastFrame]);
        }

        var kf = _keyframes[lastFrame];

        if (lastFrame == _keyframes.length - 1 || kf.index == frame) {
            x._ = kf.x;
            y._ = kf.y;
            scaleX._ = kf.scaleX;
            scaleY._ = kf.scaleY;
            rotation._ = kf.rotation;

        } else {
            var interp = (frame - kf.index)/kf.duration;
            var nextKf = _keyframes[lastFrame + 1];
            x._ = kf.x + (nextKf.x - kf.x) * interp;
            y._ = kf.y + (nextKf.y - kf.y) * interp;
            scaleX._ = kf.scaleX + (nextKf.scaleX - kf.scaleX) * interp;
            scaleY._ = kf.scaleY + (nextKf.scaleY - kf.scaleY) * interp;
            rotation._ = kf.rotation + (nextKf.rotation - kf.rotation) * interp;
        }
    }

    // private var _layerIdx :Int;
    private var _keyframes :Array<MovieKeyframe>;

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // display is swapped in at keyframe changes. If it doesn't, the display is only added to the
    // parent on layer creation.
    private var _displays :Array<Entity>;
}

