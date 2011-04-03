package flambe.display;

import flambe.animation.Property;
import flambe.math.Matrix;
import flambe.math.FMath;
import flambe.util.Signal1;

using flambe.display.Transform;
using flambe.display.Sprite;
using flambe.util.Arrays;

class Sprite extends Component
{
    public var alpha (default, null) :PFloat;
    public var visible (default, null) :PBool;

    public var mouseDown (default, null) :Signal1<MouseEvent>;
    public var mouseMove (default, null) :Signal1<MouseEvent>;
    public var mouseUp (default, null) :Signal1<MouseEvent>;

    private function new ()
    {
        this.alpha = new PFloat(1);
        this.visible = new PBool(true);
        this.mouseDown = new NotifyingSignal1(this);
        this.mouseMove = new NotifyingSignal1(this);
        this.mouseUp = new NotifyingSignal1(this);
        _viewMatrix = new Matrix();
    }

    override public function update (dt :Int)
    {
        this.alpha.update(dt);
        this.visible.update(dt);
    }

    public function draw (ctx)
    {
    }

    public function getNaturalWidth () :Int
    {
        return 0;
    }

    public function getNaturalHeight () :Int
    {
        return 0;
    }

    override public function onAttach (entity :Entity)
    {
        var transform = entity.requireTransform();
        transform.x.onUpdate.add(dirtyMatrix);
        transform.y.onUpdate.add(dirtyMatrix);
        transform.scaleX.onUpdate.add(dirtyMatrix);
        transform.scaleY.onUpdate.add(dirtyMatrix);
        transform.rotation.onUpdate.add(dirtyMatrix);
        _localMatrixDirty = true;
        super.onAttach(entity);
    }

    override public function onDetach ()
    {
        var transform = owner.getTransform();
        // TODO: Remove listeners

        if (_listenerCount > 0) {
            INTERACTIVE_SPRITES.remove(this);
        }
        super.onDetach();
    }

    private function dirtyMatrix (_)
    {
        _localMatrixDirty = true;
    }

    override public function visit (visitor :Visitor)
    {
        visitor.acceptSprite(this);
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

    private function getParentSprite ()
    {
        if (owner.parent == null) {
            return null;
        }
        return owner.parent.getSprite();
    }

    private function updateViewMatrix ()
    {
    	if (isMatrixDirty()) {
            var parentSprite = getParentSprite();
            var parentViewMatrix = if (parentSprite != null)
                parentSprite.getViewMatrix() else IDENTITY;
            var transform = owner.getTransform();
            _viewMatrix.copyFrom(parentViewMatrix);
            _viewMatrix.translate(transform.x.get(), transform.y.get());
            _viewMatrix.rotate(FMath.toRadians(transform.rotation.get()));
            _viewMatrix.scale(transform.scaleX.get(), transform.scaleY.get());

            _localMatrixDirty = false;
            if (parentSprite != null) {
                _parentMatrixUpdateCount = parentSprite._matrixUpdateCount;
            }
            ++_matrixUpdateCount;
        }
    }

    public function getViewMatrix ()
    {
    	updateViewMatrix();
    	return _viewMatrix;
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
