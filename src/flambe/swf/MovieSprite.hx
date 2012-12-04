//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.swf.MovieSymbol;
import flambe.util.Signal0;

using flambe.util.BitSets;
using flambe.util.Strings;

/**
 * An instanced Flump animation.
 */
class MovieSprite extends Sprite
{
    /** The symbol this sprite displays. */
    public var symbol (default, null) :MovieSymbol;

    /** The current playback position in seconds. */
    public var position (get_position, set_position) :Float;

    /**
     * The playback speed multiplier of this movie, defaults to 1.0. Higher values will play faster.
     */
    public var speed (default, null) :AnimatedFloat;

    /** Whether this movie is currently paused. */
    public var paused (get_paused, set_paused) :Bool;

    /** Emitted when this movie loops back to the beginning. */
    public var looped (get_looped, null) :Signal0;

    public function new (symbol :MovieSymbol)
    {
        super();
        this.symbol = symbol;

        speed = new AnimatedFloat(1);

        _animators = [];
        for (animator in symbol.layers) {
            _animators.push(new LayerAnimator(animator));
        }

        _frame = 0;
        _position = 0;
        goto(1);
    }

    /**
     * Retrieves a named layer from this movie. Children can be added to the returned entity to add
     * sprites that move with the layer, which for example, can be used to add equipment sprites to
     * an avatar.
     * @param required If true and the layer is not found, an error is thrown.
     */
    public function getLayer (name :String, required :Bool = true) :Entity
    {
        for (animator in _animators) {
            if (animator.layer.name == name) {
                return animator.content;
            }
        }
        if (required) {
            throw "Missing layer".withFields(["name", name]);
        }
        return null;
    }

    override public function onAdded ()
    {
        super.onAdded();

        for (animator in _animators) {
            owner.addChild(animator.content);
        }
    }

    override public function onRemoved ()
    {
        super.onRemoved();

        // Detach the animator content layers so they don't get disconnected during a disposal. This
        // may be a little hacky as it prevents child components from ever being formally removed.
        for (animator in _animators) {
            owner.removeChild(animator.content);
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);

        speed.update(dt);

        var looped = false;
        if (!paused) {
            _position += speed._*dt;
            if (_position > symbol.duration) {
                _position = _position % symbol.duration;
                looped = true;
            }
        }

        var newFrame = _position*symbol.frameRate;
        goto(newFrame);

        if (looped && _looped != null) {
            _looped.emit();
        }
    }

    private function goto (newFrame :Float)
    {
        if (_frame == newFrame) {
            return; // No change
        }

        var wrapped = newFrame < _frame;
        if (wrapped) {
            for (animator in _animators) {
                animator.changedKeyframe = true;
                animator.keyframeIdx = 0;
            }
        }
        for (animator in _animators) {
            animator.composeFrame(newFrame);
        }

        _frame = newFrame;
    }

    inline private function get_position () :Float
    {
        return _position;
    }

    private function set_position (position :Float) :Float
    {
        return _position = FMath.clamp(position, 0, symbol.duration);
    }

    inline private function get_paused () :Bool
    {
        return _flags.contains(Sprite.MOVIESPRITE_PAUSED);
    }

    private function set_paused (paused :Bool)
    {
        _flags = _flags.set(Sprite.MOVIESPRITE_PAUSED, paused);
        return paused;
    }

    private function get_looped () :Signal0
    {
        if (_looped == null) {
            _looped = new Signal0();
        }
        return _looped;
    }

    private var _animators :Array<LayerAnimator>;

    private var _position :Float;
    private var _frame :Float;

    private var _looped :Signal0 = null;
}

private class LayerAnimator
{
    public var content (default, null) :Entity;

    public var changedKeyframe :Bool;
    public var keyframeIdx :Int;

    public var layer :MovieLayer;

    public function new (layer :MovieLayer)
    {
        changedKeyframe = false;
        keyframeIdx = 0;
        this.layer = layer;

        content = new Entity();
        var sprite;
        if (layer.multipleSymbols) {
            _sprites = [];
            for (kf in layer.keyframes) {
                var sprite = kf.symbol.createSprite();
                _sprites.push(sprite);
            }
            sprite = _sprites[0];

        } else if (layer.lastSymbol != null) {
            sprite = layer.lastSymbol.createSprite();

        } else {
            sprite = new Sprite();
        }
        content.add(sprite);
    }

    public function composeFrame (frame :Float)
    {
        var keyframes = layer.keyframes;
        var finalFrame = keyframes.length - 1;

        while (keyframeIdx < finalFrame && keyframes[keyframeIdx+1].index <= frame) {
            ++keyframeIdx;
            changedKeyframe = true;
        }

        var sprite;
        if (changedKeyframe && _sprites != null) {
            // Switch to the next instance if this is a multi-layer symbol
            changedKeyframe = false;
            sprite = _sprites[keyframeIdx];
            content.add(sprite);
        } else {
            sprite = content.get(Sprite);
        }

        var kf = keyframes[keyframeIdx];
        var visible = kf.visible;
        sprite.visible = visible;
        if (!visible) {
            return; // Don't bother animating invisible layers
        }

        var x = kf.x;
        var y = kf.y;
        var scaleX = kf.scaleX;
        var scaleY = kf.scaleY;
        var skewX = kf.skewX;
        var skewY = kf.skewY;
        var alpha = kf.alpha;

        if (keyframeIdx < finalFrame) {
            var interp = (frame-kf.index) / kf.duration;
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

            var nextKf = keyframes[keyframeIdx + 1];
            x += (nextKf.x-x) * interp;
            y += (nextKf.y-y) * interp;
            scaleX += (nextKf.scaleX-scaleX) * interp;
            scaleY += (nextKf.scaleY-scaleY) * interp;
            skewX += (nextKf.skewX-skewX) * interp;
            skewY += (nextKf.skewY-skewY) * interp;
            alpha += (nextKf.alpha-alpha) * interp;
        }

        // From an identity matrix, append the translation, skew, and scale
        var matrix = sprite.getLocalMatrix();
        var sinX = Math.sin(skewX), cosX = Math.cos(skewX);
        var sinY = Math.sin(skewY), cosY = Math.cos(skewY);
        matrix.set(cosY*scaleX, sinY*scaleX, -sinX*scaleY, cosX*scaleY, x, y);

        // Append the pivot
        var pivotX = kf.pivotX + sprite.anchorX._;
        var pivotY = kf.pivotY + sprite.anchorY._;
        matrix.translate(-pivotX, -pivotY);

        sprite.alpha._ = alpha;
    }

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // sprite is swapped in at keyframe changes. If it doesn't, the sprite is only added to the
    // parent on layer creation.
    private var _sprites :Array<Sprite> = null;
}
