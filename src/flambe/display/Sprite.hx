package flambe.display;

import flambe.animation.Property;
import flambe.display.Transform;
import flambe.display.Sprite;
import flambe.math.Matrix;
import flambe.math.FMath;
import flambe.platform.DrawingContext;
import flambe.util.Signal1;

using flambe.util.Arrays;

class Sprite extends Component
{
    public var alpha (default, null) :PFloat;
    public var anchorX (default, null) :PFloat;
    public var anchorY (default, null) :PFloat;
    public var visible (default, null) :PBool;

    public var mouseDown (default, null) :Signal1<MouseEvent>;
    public var mouseMove (default, null) :Signal1<MouseEvent>;
    public var mouseUp (default, null) :Signal1<MouseEvent>;

    public function new ()
    {
        this.alpha = new PFloat(1);
        this.anchorX = new PFloat(0, dirtyMatrix);
        this.anchorY = new PFloat(0, dirtyMatrix);
        this.visible = new PBool(true);
        this.mouseDown = new NotifyingSignal1(this);
        this.mouseMove = new NotifyingSignal1(this);
        this.mouseUp = new NotifyingSignal1(this);
        _viewMatrix = new Matrix();
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
        transform.x.updated.add(dirtyMatrix);
        transform.y.updated.add(dirtyMatrix);
        transform.scaleX.updated.add(dirtyMatrix);
        transform.scaleY.updated.add(dirtyMatrix);
        transform.rotation.updated.add(dirtyMatrix);
        _localMatrixDirty = true;
    }

    override public function onRemoved ()
    {
        var transform = owner.get(Transform);
        // TODO: Remove listeners

        if (_listenerCount > 0) {
            INTERACTIVE_SPRITES.remove(this);
        }
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

    private function onListenerAdded ()
    {
        if (_listenerCount++ == 0) {
            // TODO: Insert in screen depth order
            INTERACTIVE_SPRITES.sortedInsert(this, function (a, b) return -1);
        }
    }

    private function onListenerRemoved ()
    {
        if (--_listenerCount == 0) {
            INTERACTIVE_SPRITES.remove(this);
        }
    }

    private static var IDENTITY = new Matrix();
    public static var INTERACTIVE_SPRITES :Array<Sprite> = [];

    private var _viewMatrix :Matrix;
    private var _localMatrixDirty :Bool;
    private var _matrixUpdateCount :Int;
    private var _parentMatrixUpdateCount :Int;

    private var _listenerCount :Int;
}

private class NotifyingSignal1<A> extends Signal1<A>
{
    public function new (sprite :Sprite)
    {
        super();
        _sprite = sprite;
    }

    override public function add (listener :Listener1<A>)
    {
        super.add(listener);
        (cast _sprite).onListenerAdded();
    }

    override public function remove (listener :Listener1<A>)
    {
        var count = _listeners.length;
        super.remove(listener);
        if (_listeners.length < count) {
            (cast _sprite).onListenerRemoved();
        }
    }

    private var _sprite :Sprite;
}
