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

        _layers = [];
        for (layer in movie.layers) {
            _layers.push(new LayerSprite(layer));
        }

        _duration = 1000/30 * movie.frames;
        _goingToFrame = false;
        _frame = 0;
        _elapsed = 0;
        goto(1);
    }

    override public function onAdded ()
    {
        super.onAdded();

        for (layer in _layers) {
            owner.addChild(new Entity().add(layer));
        }
    }

    // TODO(bruno): onRemove

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);

        _elapsed += dt;
        if (_elapsed > _duration) {
            _elapsed = _elapsed % _duration;
        }

        var newFrame = _elapsed * 30/1000;

        goto(newFrame);
    }

    private function goto (newFrame :Float)
    {
        if (_goingToFrame) {
            _pendingFrame = newFrame;
            return;
        }
        _goingToFrame = true;

        var wrapped = newFrame < _frame;
        if (wrapped) {
            for (layer in _layers) {
                layer.changedKeyframe = true;
                layer.keyframeIdx = 0;
            }
        }
        for (layer in _layers) {
            layer.composeFrame(newFrame);
        }

        // var oldFrame = _frame;
        _frame = newFrame;

        _goingToFrame = false;
        if (_pendingFrame != -1) {
            newFrame = _pendingFrame;
            _pendingFrame = -1;
            goto(newFrame);
        }
    }

    private var _lib :Library;

    private var _layers :Array<LayerSprite>;
    private var _duration :Float;
    private var _elapsed :Float;

    private var _frame :Float;
    private var _goingToFrame :Bool;
    private var _pendingFrame :Float;
}

private class LayerSprite extends Sprite
{
    public var changedKeyframe :Bool;
    public var keyframeIdx :Int;

    public function new (layer :MovieLayer)
    {
        super();
        changedKeyframe = false;
        keyframeIdx = 0;
        _keyframes = layer.keyframes;
        _content = new Entity();

        if (layer.multipleSymbols) {
            _sprites = [];
            for (kf in _keyframes) {
                var sprite = kf.symbol.createSprite();
                _sprites.push(sprite);
            }
            _content.add(_sprites[0]);

        } else if (layer.lastSymbol != null) {
            _content.add(layer.lastSymbol.createSprite());
        } else {
            // setSprite(new Sprite());
        }
    }

    override public function onAdded ()
    {
        super.onAdded();

        owner.addChild(_content);
    }

    // TODO(bruno): onRemove

    public function composeFrame (frameFloat :Float)
    {
        var frameInt = Std.int(frameFloat);
        while (keyframeIdx < _keyframes.length - 1
                && _keyframes[keyframeIdx + 1].index <= frameInt) {
            ++keyframeIdx;
            changedKeyframe = true;
        }

        if (changedKeyframe && _sprites != null) {
            // TODO(bruno): Test multi-symbol layers
            _content.add(_sprites[keyframeIdx]);
        }

        var kf = _keyframes[keyframeIdx];

        if (keyframeIdx == _keyframes.length - 1 || kf.index == frameInt) {
            x._ = kf.x;
            y._ = kf.y;
            scaleX._ = kf.scaleX;
            scaleY._ = kf.scaleY;
            rotation._ = kf.rotation;
            alpha._ = kf.alpha;

        } else {
            var interp = (frameFloat - kf.index)/kf.duration;
            var nextKf = _keyframes[keyframeIdx + 1];
            x._ = kf.x + (nextKf.x - kf.x) * interp;
            y._ = kf.y + (nextKf.y - kf.y) * interp;
            scaleX._ = kf.scaleX + (nextKf.scaleX - kf.scaleX) * interp;
            scaleY._ = kf.scaleY + (nextKf.scaleY - kf.scaleY) * interp;
            rotation._ = kf.rotation + (nextKf.rotation - kf.rotation) * interp;
            alpha._ = kf.alpha + (nextKf.alpha - kf.alpha) * interp;
        }
    }

    private var _keyframes :Array<MovieKeyframe>;

    private var _content :Entity;

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // sprite is swapped in at keyframe changes. If it doesn't, the sprite is only added to the
    // parent on layer creation.
    private var _sprites :Array<Sprite>;
}

