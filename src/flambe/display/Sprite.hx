//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.Property;
import flambe.display.Transform;
import flambe.display.Sprite;
import flambe.math.Matrix;
import flambe.math.FMath;
import flambe.util.Signal1;

class Sprite extends Component
{
    public var alpha (default, null) :PFloat;
    public var anchorX (default, null) :PFloat;
    public var anchorY (default, null) :PFloat;
    public var visible (default, null) :PBool;

    public var blendMode :BlendMode;

    public var mouseDown (default, null) :Signal1<MouseEvent>;
    public var mouseMove (default, null) :Signal1<MouseEvent>;
    public var mouseUp (default, null) :Signal1<MouseEvent>;

    public function new ()
    {
        this.alpha = new PFloat(1);
        this.anchorX = new PFloat(0, dirtyMatrix);
        this.anchorY = new PFloat(0, dirtyMatrix);
        this.visible = new PBool(true);
        this.blendMode = null;
        this.mouseDown = new NotifyingSignal1(this);
        this.mouseMove = new NotifyingSignal1(this);
        this.mouseUp = new NotifyingSignal1(this);

        _viewMatrix = new Matrix();
        _listenerCount = 0;
    }

    override public function onUpdate (dt :Int)
    {
        this.alpha.update(dt);
        this.anchorX.update(dt);
        this.anchorY.update(dt);
        this.visible.update(dt);
    }

    public function draw (ctx :DrawingContext)
    {
    }

    public function getNaturalWidth () :Float
    {
        return 0;
    }

    public function getNaturalHeight () :Float
    {
        return 0;
    }

    override public function onAdded ()
    {
        var transform = owner.get(Transform);
        if (transform == null) {
            owner.add(transform = new Transform());
        }
        transform.x.updated.connect(dirtyMatrix);
        transform.y.updated.connect(dirtyMatrix);
        transform.scaleX.updated.connect(dirtyMatrix);
        transform.scaleY.updated.connect(dirtyMatrix);
        transform.rotation.updated.connect(dirtyMatrix);
        _localMatrixDirty = true;
    }

    override public function onRemoved ()
    {
        var transform = owner.get(Transform);

        if (_listenerCount > 0) {
            _internal_interactiveSprites.remove(this);
        }
    }

    override public function onDispose ()
    {
        // Should this be standard practice?
        mouseDown.disconnectAll();
        mouseMove.disconnectAll();
        mouseUp.disconnectAll();
    }

    private function dirtyMatrix (_)
    {
        _localMatrixDirty = true;
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
            var transform = owner.get(Transform);
            _viewMatrix.copyFrom(parentViewMatrix);
            _viewMatrix.translate(transform.x.get(), transform.y.get());
            _viewMatrix.rotate(FMath.toRadians(transform.rotation.get()));
            _viewMatrix.scale(transform.scaleX.get(), transform.scaleY.get());
            _viewMatrix.translate(-anchorX.get(), -anchorY.get());

            _localMatrixDirty = false;
            if (parentSprite != null) {
                _parentMatrixUpdateCount = parentSprite._matrixUpdateCount;
            }
            ++_matrixUpdateCount;
        }
    }

    public function getViewMatrix () :Matrix
    {
    	updateViewMatrix();
    	return _viewMatrix;
    }

    public function centerAnchor ()
    {
        anchorX.set(getNaturalWidth()/2);
        anchorY.set(getNaturalHeight()/2);
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

    // All sprites that have mouse listeners attached, in screen depth order.
    // Used to optimize mouse picking.
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
