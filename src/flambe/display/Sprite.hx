//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.Property;
import flambe.display.Sprite;
import flambe.input.PointerEvent;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.util.Signal1;

class Sprite extends Component
{
    public var x (default, null) :PFloat;
    public var y (default, null) :PFloat;
    public var rotation (default, null) :PFloat;
    public var scaleX (default, null) :PFloat;
    public var scaleY (default, null) :PFloat;

    public var anchorX (default, null) :PFloat;
    public var anchorY (default, null) :PFloat;

    public var alpha (default, null) :PFloat;
    public var blendMode :BlendMode;
    public var visible (default, null) :PBool;

    public var pointerDown (default, null) :Signal1<PointerEvent>;
    public var pointerMove (default, null) :Signal1<PointerEvent>;
    public var pointerUp (default, null) :Signal1<PointerEvent>;

    public function new ()
    {
        x = new PFloat(0, dirtyMatrix);
        y = new PFloat(0, dirtyMatrix);
        rotation = new PFloat(0, dirtyMatrix);
        scaleX = new PFloat(1, dirtyMatrix);
        scaleY = new PFloat(1, dirtyMatrix);

        alpha = new PFloat(1);
        anchorX = new PFloat(0, dirtyMatrix);
        anchorY = new PFloat(0, dirtyMatrix);
        visible = new PBool(true);
        blendMode = null;
        pointerDown = new NotifyingSignal1(this);
        pointerMove = new NotifyingSignal1(this);
        pointerUp = new NotifyingSignal1(this);

        _viewMatrix = new Matrix();
        _localMatrixDirty = false;
        _listenerCount = 0;
    }

    public function getNaturalWidth () :Float
    {
        return 0;
    }

    public function getNaturalHeight () :Float
    {
        return 0;
    }

    public function contains (viewX :Float, viewY :Float) :Bool
    {
        updateViewMatrix();
        var localX = _viewMatrix.inverseTransformX(viewX, viewY);
        var localY = _viewMatrix.inverseTransformY(viewX, viewY);
        if (localX == Math.NaN || localY == Math.NaN) {
            return false;
        }
        return containsLocal(localX, localY);
    }

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

    inline public function setAnchor (x :Float, y :Float)
    {
        anchorX._ = x;
        anchorY._ = y;
    }

    inline public function centerAnchor ()
    {
        anchorX._ = getNaturalWidth()/2;
        anchorY._ = getNaturalHeight()/2;
    }

    inline public function setXY (x :Float, y :Float)
    {
        this.x._ = x;
        this.y._ = y;
    }

    inline public function setScale (scale :Float)
    {
        scaleX._ = scale;
        scaleY._ = scale;
    }

    inline public function setScaleXY (scaleX :Float, scaleY :Float)
    {
        this.scaleX._ = scaleX;
        this.scaleY._ = scaleY;
    }

    override public function onUpdate (dt :Int)
    {
        x.update(dt);
        y.update(dt);
        rotation.update(dt);
        scaleX.update(dt);
        scaleY.update(dt);
        alpha.update(dt);
        anchorX.update(dt);
        anchorY.update(dt);
        visible.update(dt);
    }

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

    private function dirtyMatrix (_)
    {
        _localMatrixDirty = true;
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
        return (owner.parent == null) ? null : owner.parent.get(Sprite);
    }

    private function updateViewMatrix ()
    {
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

    public function _internal_onListenersAdded (count :Int)
    {
        if (_listenerCount == 0) {
            // TODO: Insert in screen depth order
            _internal_interactiveSprites.unshift(this);
        }
        _listenerCount += count;
    }

    public function _internal_onListenersRemoved (count :Int)
    {
        _listenerCount -= count;
        if (_listenerCount == 0) {
            _internal_interactiveSprites.remove(this);
        }
    }

    private static var IDENTITY = new Matrix();

    // All sprites that have input event listeners attached, in screen depth order.
    // Used to optimize picking.
    public static var _internal_interactiveSprites :Array<Sprite> = [];

    private var _viewMatrix :Matrix;
    private var _localMatrixDirty :Bool;
    private var _matrixUpdateCount :Int;
    private var _parentMatrixUpdateCount :Int;

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
