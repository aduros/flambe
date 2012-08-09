//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.swf.MovieSymbol;

/**
 * An instanced Flump animation.
 */
class MovieSprite extends Sprite
{
    /**
     * The symbol this sprite displays.
     */
    public var symbol (default, null) :MovieSymbol;

    /**
     * The current playback position in seconds.
     */
    public var position (getPosition, setPosition) :Float;

    /**
     * The playback speed multiplier of this movie, defaults to 1.0. Higher values will play faster.
     */
    public var speed (default, null) :AnimatedFloat;

    public function new (symbol :MovieSymbol)
    {
        super();
        this.symbol = symbol;

        speed = new AnimatedFloat(1);

        _layers = [];
        for (layer in symbol.layers) {
            _layers.push(new LayerSprite(layer));
        }

        _frame = 0;
        _position = 0;
        goto(1);
    }

    override public function onAdded ()
    {
        super.onAdded();

        for (layer in _layers) {
            owner.addChild(new Entity().add(layer));
        }
    }

    override public function onRemoved ()
    {
        super.onRemoved();

        for (layer in _layers) {
            owner.removeChild(layer.owner);
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);

        speed.update(dt);

        _position += speed._*dt;
        if (_position > symbol.duration) {
            _position = _position % symbol.duration;
        }

        var newFrame = _position*symbol.frameRate;
        goto(newFrame);
    }

    private function goto (newFrame :Float)
    {
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

        _frame = newFrame;
    }

    inline private function getPosition () :Float
    {
        return _position;
    }

    private function setPosition (position :Float) :Float
    {
        return _position = FMath.clamp(position, 0, symbol.duration);
    }

    private var _layers :Array<LayerSprite>;

    private var _position :Float;
    private var _frame :Float;
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
            var ease = kf.ease;
            if (ease != 0) {
                var t;
                if (ease < 0) {
                    // Ease in
                    var inv = 1 - interp;
                    t = 1 - inv*inv;
                    ease = -ease;
                } else {
                    // Ease out
                    t = interp*interp;
                }
                interp = ease*t + (1 - ease)*interp;
            }

            var nextKf = _keyframes[keyframeIdx + 1];
            x._ = kf.x + (nextKf.x - kf.x) * interp;
            y._ = kf.y + (nextKf.y - kf.y) * interp;
            scaleX._ = kf.scaleX + (nextKf.scaleX - kf.scaleX) * interp;
            scaleY._ = kf.scaleY + (nextKf.scaleY - kf.scaleY) * interp;
            rotation._ = kf.rotation + (nextKf.rotation - kf.rotation) * interp;
            alpha._ = kf.alpha + (nextKf.alpha - kf.alpha) * interp;
        }

        anchorX._ = kf.pivotX;
        anchorY._ = kf.pivotY;
        visible._ = kf.visible;
    }

    private var _keyframes :Array<MovieKeyframe>;

    private var _content :Entity;

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // sprite is swapped in at keyframe changes. If it doesn't, the sprite is only added to the
    // parent on layer creation.
    private var _sprites :Array<Sprite>;
}
