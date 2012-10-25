//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.swf.MovieSymbol;

using flambe.util.Strings;

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
	
    private function get_frame():Float 
    {
        return _frame;
    }
    
    private function set_frame(value:Float):Float 
    {
        goto(value);
        return _frame;
    }
    
    public var frame(get_frame, set_frame):Float;
    
    private function get_totalFrames():Float 
    {
        return symbol.duration / symbol.frameRate;
    }

    public var totalFrames(get_totalFrames, null):Float;

    /**
     * Whether this movie is currently paused.
     */
    public var paused :Bool = false;

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

        for (animator in _animators) {
            owner.removeChild(animator.content);
        }
    }

    override public function onDispose ()
    {
        super.onDispose();

        for (animator in _animators) {
            animator.content.dispose();
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);

        if (speed._ == 0)
        {
            return;
        }
        speed.update(dt);

        if (!paused) {
            _position += speed._*dt;
            if (_position > symbol.duration) {
                _position = _position % symbol.duration;
            }

            var newFrame = _position*symbol.frameRate;
            goto(newFrame);
        }
    }
    

    /**
     * Go to a specific frame
     * @param newFrame - First frame is zero
     */
    public function goto (newFrame :Float)
    {
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
        
        if (_endPosition > 0 && _position >= _endPosition) {
            stop();
            _endPosition = 0;
        }
    }
    
    
    
    /**
     * Set the speed to zero
     */
    public function stop():Void
    {
        speed._ = 0;
    }
    
    /**
     * Set the speed to 1
     */
    public function play():Void
    {
        speed._ = 1;
    }
    
    
    /**
     * Set the speed to 1 and the endFrame that will trigger stop()
     * @param    position from 
     */
    public function playTo(position:Float):Void
    {
        _endPosition = position;
        speed._ = 1;
    }
    
    
    
    /**
     * Go to a specific frame and set speed to zero
     * @param    newFrame First frame is zero
     */
    public function gotoAndStop(newFrame:Float):Void
    {
        speed._ = 0;
        goto(newFrame);
    }
    
    /**
     * Go to a specific frame and set speed to 1
     * @param    newFrame First frame is zero
     */
    public function gotoAndPlay(newFrame:Float):Void
    {
        speed._ = 1;
        goto(newFrame);
    }

    inline private function getPosition () :Float
    {
        return _position;
    }

    private function setPosition (position :Float) :Float
    {
        return _position = FMath.clamp(position, 0, symbol.duration);
    }

    private var _animators :Array<LayerAnimator>;

    private var _position :Float;
    private var _frame :Float;
    
    /**
     * Last position to stop at
     */
    private var _endPosition:Float = 0;
    
    private var _frameSprite:Sprite;
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
        var rotation = kf.rotation;
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
            rotation += (nextKf.rotation-rotation) * interp;
            alpha += (nextKf.alpha-alpha) * interp;
        }

        sprite.x._ = x;
        sprite.y._ = y;
        sprite.scaleX._ = scaleX;
        sprite.scaleY._ = scaleY;
        sprite.rotation._ = rotation;
        sprite.alpha._ = alpha;
        sprite.anchorX._ = kf.pivotX;
        sprite.anchorY._ = kf.pivotY;
    }

    // Only created if there are multiple symbols on this layer. If it does exist, the appropriate
    // sprite is swapped in at keyframe changes. If it doesn't, the sprite is only added to the
    // parent on layer creation.
    private var _sprites :Array<Sprite>;
}
