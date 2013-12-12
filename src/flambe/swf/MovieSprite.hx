//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;

import flambe.swf.MovieSymbol;
import flambe.util.Signal0;
import flambe.util.Signal1.Signal1;


using flambe.util.Arrays;
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
    public var position (get, set) :Float;

    /**
     * The playback speed multiplier of this movie, defaults to 1.0. Higher values will play faster.
     * This does not affect the speed of nested child movies, use `flambe.SpeedAdjuster` if you need
     * that.
     */
    public var speed (default, null) :AnimatedFloat;
	
	/** get/set the current frame (playhead position) **/
    public var frame(get, set):Float;

	/* The total number of frames in this MovieSprite */
	public var totalFrames(get_totalFrames, never):Int;
	
    /** Whether this movie is currently paused. */
    public var paused (get, set) :Bool;

    /** Emitted when this movie loops back to the beginning. */
    public var looped (get, null) :Signal0;
	
    /** Emitted when the playhead passes a label keyframe on the 'labels' layer. */
	public var labelPassed(default, null):Signal1<String>;
	
	/** true if a 'labels' layer has been detected and parsed **/
	public var hasFrameLabels(default, null):Bool = false;
	
	public var frameLabels(get, never):Array<String>;
	
	
    public function new (symbol :MovieSymbol)
    {
        super();
		
        this.symbol = symbol;
		
		readFrameLabels();
		
        speed 		= new AnimatedFloat(1);
		labelPassed = new Signal1<String>();
		
        _animators = Arrays.create(symbol.layers.length);
        for (ii in 0..._animators.length) {
            var layer = symbol.layers[ii];
            _animators[ii] = new LayerAnimator(layer, this);
        }
		
        _frame = -1;
        _position = 0;
		_lastLabelFrame = -1;
        goto(0);
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
		
	
	/**
	 * Get the frame index for a frame-label keyframe on the 'labels' layer.
	 * @param	name
	 * @return The frame index, or -1 if no label was found for the passed name
	 */
	public function findLabel(name:String):Float {
		return hasFrameLabels && _labelsToFrames.exists(name) ? _labelsToFrames.get(name) : -1;
	}
	
	/**
	 *
	 * @param	stopChildLayers
	 */
	public function stop(stopChildLayers:Bool=false) {
		speed._ = 0;
		if(stopChildLayers) {
			for (ani in _animators) {
				var spr = ani.content.get(MovieSprite);
				if (Type.getClass(spr) == MovieSprite) spr.stop();
			}
		}
	}
	
	/**
	 *
	 * @param	playChildLayers
	 */
	public function play(playChildLayers:Bool=false) {
		speed._ = 1;
		if(playChildLayers) {
			for (ani in _animators) {
				var spr = ani.content.get(MovieSprite);
				if (Type.getClass(spr) == MovieSprite) spr.play();
			}
		}
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

		if (speed._ == 0) return;
		
        speed.update(dt);

        switch (_flags & (Sprite.MOVIESPRITE_PAUSED | Sprite.MOVIESPRITE_SKIP_NEXT)) {
        case 0:
            // Neither paused nor skipping set, advance time
            _position += speed._ * dt;
            if (_position > symbol.duration) {
                _position = _position % symbol.duration;
                if (_looped != null) {
                    _looped.emit();
                }
            }
        case Sprite.MOVIESPRITE_SKIP_NEXT:
            // Not paused, but skip this time step
            _flags = _flags.remove(Sprite.MOVIESPRITE_SKIP_NEXT);
        }

        var newFrame = _position * symbol.frameRate;
        goto(newFrame);
    }

	
    function goto (newFrame :Float)
    {
        if (_frame == newFrame) {
            return; // No change
        }

        var wrapped = newFrame < _frame;
        if (wrapped) {
            for (animator in _animators) {
                animator.needsKeyframeUpdate = true;
                animator.keyframeIdx = 0;
            }
        }
        for (animator in _animators) {
            animator.composeFrame(newFrame);
        }
		
        _frame = newFrame;
		
		if (hasFrameLabels) {
			var iframe = Std.int(_frame);
			if (iframe != _lastLabelFrame && _framesToLabels.exists(iframe)) {
				_lastLabelFrame = iframe;
				labelPassed.emit(_framesToLabels.get(iframe));
			}
        }
    }
	
	/**
	 *
	 */
	function readFrameLabels() {
		hasFrameLabels 	= false;
		
		var labelsLayer	= getSymbolLayerByName('labels');
		
		#if debug
		if (labelsLayer != null) {
			if (!labelsLayer.empty) trace('MovieSprite "labels" layers should not contain any symbol instances.');
			// not an error... but not expected.
		}
		#end
		
		if (labelsLayer != null) {
			
			var labelKeyFrames 	= labelsLayer.keyframes;
			hasFrameLabels 		= labelKeyFrames != null && labelKeyFrames.length > 0;
			_framesToLabels		= new Map<Int, String>();
			_labelsToFrames		= new Map<String, Int>();
			
			for (k in labelKeyFrames) {
				_framesToLabels.set(k.index, k.label);
				_labelsToFrames.set(k.label, k.index);
			}
		}
	}
	
	/**
	 * Direct access to a MovieLayer (swf timeline layer) by name.
	 * This expects layers in a movieclip to have unique names (it will only return the first layer found)
	 * @param	name
	 * @return
	 */
	function getSymbolLayerByName(name:String):MovieLayer {
		var layers = Lambda.filter(symbol.layers, function(layer) { return layer.name == name; } );
		if (layers != null && layers.length > 0) return layers.first();
		return null;
	}
	
	
    inline function get_position () :Float
	{
		return _position;
	}
	
    function set_position (position :Float) :Float
	{
		return _position = FMath.clamp(position, 0, symbol.duration);
	}

    inline function get_paused () :Bool
	{
		return _flags.contains(Sprite.MOVIESPRITE_PAUSED);
	}

    function set_paused (paused :Bool)
	{
        _flags = _flags.set(Sprite.MOVIESPRITE_PAUSED, paused);
        return paused;
    }

    function get_looped () :Signal0
    {
        if (_looped == null) {
            _looped = new Signal0();
        }
        return _looped;
    }
	
	
    inline function get_frame():Float return _frame;
    inline function set_frame(value:Float):Float {
        _position = value / symbol.frameRate;
		goto(value);
		return _frame;
    }
	
	inline function get_totalFrames():Int return Math.ceil(symbol.duration / symbol.frameRate);
	
	function get_frameLabels() {
		if (_frameLabels == null && hasFrameLabels) _frameLabels = Lambda.array(_framesToLabels);
		return _frameLabels;
	}
	

    /**
     * Internal method to set the position to 0 and skip the next update. This is required to modify
     * the playback position of child movies during an update step, so that after the update
     * trickles through the children, they end up at position=0 instead of position=dt.
     */
    @:allow(flambe) function rewind ()
    {
        _position = 0;
		_lastLabelFrame = -1;
        _flags = _flags.add(Sprite.MOVIESPRITE_SKIP_NEXT);
    }

    var _animators :Array<LayerAnimator>;
	var _position :Float;
    var _frame :Float;
	
	var _looped :Signal0 = null;
	
	// frame labels...
	var _framesToLabels:Map<Int,String>;
	var _labelsToFrames:Map<String,Int>;
	var _lastLabelFrame:Int = -1;
	var _frameLabels:Array<String>;
}

private class LayerAnimator
{
    public var content (default, null) :Entity;

    public var needsKeyframeUpdate:Bool = false;
    public var keyframeIdx :Int = 0;
	
    public var layer		:MovieLayer;
	
    public function new (layer :MovieLayer)
    {
        this.layer = layer;

        content = new Entity();
        if (layer.empty) {
            _sprites = null;
        } else {
            // Populate _sprites with the Sprite at each keyframe, reusing consecutive symbols
            _sprites = Arrays.create(layer.keyframes.length);
            for (ii in 0..._sprites.length) {
                var kf = layer.keyframes[ii];
                if (ii > 0 && layer.keyframes[ii-1].symbol == kf.symbol) {
                    _sprites[ii] = _sprites[ii-1];
                } else if (kf.symbol == null) {
                    _sprites[ii] = new Sprite();
                } else {
                    _sprites[ii] = kf.symbol.createSprite();
                }
            }
            content.add(_sprites[0]);
        }
    }

    public function composeFrame (frame :Float)
    {
        if (_sprites == null) {
            // TODO(bruno): Test this code path
            // Don't animate empty layers
            return;
        }

        var keyframes = layer.keyframes;
        var finalFrame = keyframes.length - 1;

        if (frame > layer.frames) {
            // TODO(bruno): Test this code path
            // Not enough frames on this layer, hide it
            content.get(Sprite).visible = false;
            keyframeIdx = finalFrame;
            needsKeyframeUpdate = true;
            return;
        }

        while (keyframeIdx < finalFrame && keyframes[keyframeIdx+1].index <= frame) {
            ++keyframeIdx;
            needsKeyframeUpdate = true;
        }

        var sprite;
        if (needsKeyframeUpdate) {
            needsKeyframeUpdate = false;
            // Switch to the next instance if this is a multi-layer symbol
            sprite = _sprites[keyframeIdx];
            if (sprite != content.get(Sprite)) {
                if (Type.getClass(sprite) == MovieSprite) {
                    var movie :MovieSprite = cast sprite;
                    movie.rewind();
                }
                content.add(sprite);
            }
        } else {
            sprite = content.get(Sprite);
        }

        var kf = keyframes[keyframeIdx];
        var visible = kf.visible && kf.symbol != null;
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
		
        if (kf.tweened && keyframeIdx < finalFrame) {
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
        matrix.set(cosY * scaleX, sinY * scaleX, -sinX * scaleY, cosX * scaleY, x, y);

        // Append the pivot
        matrix.translate(-kf.pivotX, -kf.pivotY);
		
		sprite.alpha._ = alpha;
    }

    // The sprite to show at each keyframe index, or null if this layer has no symbol instances
    var _sprites :Array<Sprite>;
}
