//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.geom.Transform;
import flambe.Component;
import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.input.PointerEvent;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.math.Point;
import flambe.util.Signal1;
import flambe.util.Value;

class Sprite extends Component
{
    /**
     * X position, in pixels.
     */
    public var x (default, null) :AnimatedFloat;

    /**
     * Y position, in pixels.
     */
    public var y (default, null) :AnimatedFloat;

    /**
     * Rotation angle, in degrees.
     */
    public var rotation (default, null) :AnimatedFloat;

    /**
     * Horizontal scale factor.
     */
    public var scaleX (default, null) :AnimatedFloat;

    /**
     * Vertical scale factor.
     */
    public var scaleY (default, null) :AnimatedFloat;

    /**
     * The X position of this sprite's anchor point. Local transformations are applied relative to
     * this point.
     */
    public var anchorX (default, null) :AnimatedFloat;

    /**
     * The Y position of this sprite's anchor point. Local transformations are applied relative to
     * this point.
     */
    public var anchorY (default, null) :AnimatedFloat;

    /**
     * The alpha (opacity) of this sprite, between 0 (invisible) and 1 (fully opaque).
     */
    public var alpha (default, null) :AnimatedFloat;

    /**
     * The blend mode used to draw this sprite, or null to use its parent's blend mode.
     */
    public var blendMode :BlendMode;

    /**
     * True if this sprite should be drawn.
     */
    public var visible (default, null) :Value<Bool>;

    /**
     * Emitted when the pointer is pressed down over this sprite.
     */
    public var pointerDown (getPointerDown, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is moved over this sprite.
     */
    public var pointerMove (getPointerMove, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is raised over this sprite.
     */
    public var pointerUp (getPointerUp, null) :Signal1<PointerEvent>;

/**
     same as as3 Transform
**/
    public var transform(getTransform, setTransform) : Transform;


    private var _transform:Transform;

    public function new ()
    {
        var dirtyMatrix = function (_,_) {
            _localMatrixDirty = true;
        };
        x = new AnimatedFloat(0, dirtyMatrix);
        y = new AnimatedFloat(0, dirtyMatrix);
        rotation = new AnimatedFloat(0, dirtyMatrix);
        scaleX = new AnimatedFloat(1, dirtyMatrix);
        scaleY = new AnimatedFloat(1, dirtyMatrix);

        alpha = new AnimatedFloat(1);
        anchorX = new AnimatedFloat(0, dirtyMatrix);
        anchorY = new AnimatedFloat(0, dirtyMatrix);
        visible = new Value<Bool>(true);
        blendMode = null;

        _localMatrixDirty = false;
        _listenerCount = 0;
    }

    /**
     * The "natural" width of this sprite, without any transformations being applied. Used for hit
     * testing.
     */
    public function getNaturalWidth () :Float
    {
        return 0;
    }

    /**
     * The "natural" height of this sprite, without any transformations being applied. Used for hit
     * testing.
     */
    public function getNaturalHeight () :Float
    {
        return 0;
    }

    /**
     * Returns true if the given point (in viewport/stage coordinates) lies inside this sprite.
     */
    public function contains (viewX :Float, viewY :Float) :Bool
    {
        return getViewMatrix().inverseTransform(viewX, viewY, _scratchPoint) &&
            containsLocal(_scratchPoint.x, _scratchPoint.y);
    }

    /**
     * Returns true if the given point (in local coordinates) lies inside this sprite.
     */
    public function containsLocal (localX :Float, localY :Float) :Bool
    {
        return localX >= 0 && localX < getNaturalWidth()
            && localY >= 0 && localY < getNaturalHeight();
    }

    public function getViewMatrix () :Matrix
    {
        updateViewMatrix();
        return _viewMatrix;
    }

    inline public function setAnchor (x :Float, y :Float) :Sprite
    {
        anchorX._ = x;
        anchorY._ = y;
        return this;
    }

    inline public function centerAnchor () :Sprite
    {
        anchorX._ = getNaturalWidth()/2;
        anchorY._ = getNaturalHeight()/2;
        return this;
    }

    inline public function setXY (x :Float, y :Float) :Sprite
    {
        this.x._ = x;
        this.y._ = y;
        return this;
    }

    inline public function setScale (scale :Float) :Sprite
    {
        scaleX._ = scale;
        scaleY._ = scale;
        return this;
    }

    inline public function setScaleXY (scaleX :Float, scaleY :Float) :Sprite
    {
        this.scaleX._ = scaleX;
        this.scaleY._ = scaleY;
        return this;
    }

    override public function onUpdate (dt :Float)
    {
        x.update(dt);
        y.update(dt);
        rotation.update(dt);
        scaleX.update(dt);
        scaleY.update(dt);
        alpha.update(dt);
        anchorX.update(dt);
        anchorY.update(dt);
    }

    /**
     * Draws this sprite to the given DrawingContext.
     */
    public function draw (ctx :DrawingContext)
    {
        // See subclasses
    }

    override public function onAdded ()
    {
        if (_listenerCount > 0) {
            // TODO: Insert in screen depth order
            _internal_interactiveSprites.unshift(this);
        }
    }

    override public function onRemoved ()
    {
        if (_listenerCount > 0) {
            _internal_interactiveSprites.remove(this);
        }
    }

    private function isMatrixDirty () :Bool
    {
        if (_localMatrixDirty) {
            return true;
        }
        var parentSprite = getParentSprite();
        if (parentSprite == null) {
            return false;
        }
        return _parentMatrixUpdateCount != parentSprite._matrixUpdateCount
            || parentSprite.isMatrixDirty();
    }

    private function getParentSprite () :Sprite
    {
        var entity = owner.parent;
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                return sprite;
            }
            entity = entity.parent;
        }
        return null;
    }

    private function updateViewMatrix ()
    {
        if (_viewMatrix == null) {
            _viewMatrix = new Matrix();
        }
        if (isMatrixDirty()) {
            var parentSprite = getParentSprite();
            var parentViewMatrix = if (parentSprite != null)
                parentSprite.getViewMatrix() else IDENTITY;
            _viewMatrix.copyFrom(parentViewMatrix);
            _viewMatrix.translate(x._, y._);
            _viewMatrix.rotate(FMath.toRadians(rotation._));
            _viewMatrix.scale(scaleX._, scaleY._);
            _viewMatrix.translate(-anchorX._, -anchorY._);

            _localMatrixDirty = false;
            if (parentSprite != null) {
                _parentMatrixUpdateCount = parentSprite._matrixUpdateCount;
            }
            ++_matrixUpdateCount;
        }
    }

    private function getPointerDown ()
    {
        if (_internal_pointerDown == null) {
            _internal_pointerDown = new NotifyingSignal1(this);
        }
        return _internal_pointerDown;
    }

    private function getPointerMove ()
    {
        if (_internal_pointerMove == null) {
            _internal_pointerMove = new NotifyingSignal1(this);
        }
        return _internal_pointerMove;
    }

    private function getPointerUp ()
    {
        if (_internal_pointerUp == null) {
            _internal_pointerUp = new NotifyingSignal1(this);
        }
        return _internal_pointerUp;
    }


    private function getTransform():Transform{

        return _transform;
    }

    private function setTransform(_:Transform):Void{

        _transform=_;
    }
    /** @private */ public function _internal_onListenersAdded (count :Int)
    {
        if (_listenerCount == 0) {
            // TODO: Insert in screen depth order
            _internal_interactiveSprites.unshift(this);
        }
        _listenerCount += count;
    }

    /** @private */ public function _internal_onListenersRemoved (count :Int)
    {
        _listenerCount -= count;
        if (_listenerCount == 0) {
            _internal_interactiveSprites.remove(this);
        }
    }

    private static var IDENTITY = new Matrix();
    private static var _scratchPoint = new Point();

    // All sprites that have input event listeners attached, in screen depth order.
    // Used to optimize picking.
    /** @private */ public static var _internal_interactiveSprites :Array<Sprite> = [];

    private var _viewMatrix :Matrix;
    private var _localMatrixDirty :Bool;
    private var _matrixUpdateCount :Int;
    private var _parentMatrixUpdateCount :Int;

    /** @private */ public var _internal_pointerDown :Signal1<PointerEvent>;
    /** @private */ public var _internal_pointerMove :Signal1<PointerEvent>;
    /** @private */ public var _internal_pointerUp :Signal1<PointerEvent>;

    private var _listenerCount :Int;
}

import flambe.util.Signal1;
import flambe.util.SignalConnection;
import flambe.util.SignalImpl;

private class NotifyingSignal1<A> extends Signal1<A>
{
    public function new (sprite :Sprite)
    {
        super();
        _sprite = sprite;
    }

    override private function createImpl () :SignalImpl
    {
        return new NotifyingSignalImpl(_sprite);
    }

    private var _sprite :Sprite;
}

private class NotifyingSignalImpl extends SignalImpl
{
    public function new (sprite :Sprite)
    {
        super();
        _sprite = sprite;
    }

    override public function connect (listener :Dynamic, prioritize :Bool) :SignalConnection
    {
        _sprite._internal_onListenersAdded(1);
        return super.connect(listener, prioritize);
    }

    override public function disconnect (connection :SignalConnection) :Bool
    {
        if (super.disconnect(connection)) {
            _sprite._internal_onListenersRemoved(1);
            return true;
        }
        return false;
    }

    override public function disconnectAll ()
    {
        _sprite._internal_onListenersRemoved(_connections.length);
        super.disconnectAll();
    }

    private var _sprite :Sprite;
}
