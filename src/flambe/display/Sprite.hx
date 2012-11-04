//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;
import flambe.input.PointerEvent;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.math.Point;
import flambe.math.Rectangle;
import flambe.scene.Director;
import flambe.util.Signal1;
import flambe.util.Value;

using flambe.util.BitSets;

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
    public var blendMode :BlendMode = null;

    /**
     * Whether this sprite should be drawn.
     */
    public var visible (getVisible, setVisible) :Bool;

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
     * Whether this sprite or any children should receive pointer events. Defaults to true.
     */
    public var pointerEnabled (isPointerEnabled, setPointerEnabled) :Bool;

    public function new ()
    {
        _flags = VISIBLE | POINTER_ENABLED | VIEW_MATRIX_DIRTY;
        _localMatrix = new Matrix();

        var dirtyMatrix = function (_,_) {
            _flags = _flags.add(LOCAL_MATRIX_DIRTY | VIEW_MATRIX_DIRTY);
        };
        x = new AnimatedFloat(0, dirtyMatrix);
        y = new AnimatedFloat(0, dirtyMatrix);
        rotation = new AnimatedFloat(0, dirtyMatrix);
        scaleX = new AnimatedFloat(1, dirtyMatrix);
        scaleY = new AnimatedFloat(1, dirtyMatrix);
        anchorX = new AnimatedFloat(0, dirtyMatrix);
        anchorY = new AnimatedFloat(0, dirtyMatrix);

        alpha = new AnimatedFloat(1);
    }

    /**
     * Search for a sprite in the entity hierarchy lying under the given point, in local
     * coordinates. Ignores sprites that are invisible or not pointerEnabled during traversal.
     * Returns null if neither the entity or its children contain a sprite under the given point.
     */
    public static function hitTest (entity :Entity, x :Float, y :Float) :Sprite
    {
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            if (!sprite._flags.containsAll(VISIBLE | POINTER_ENABLED)) {
                return null; // Prune invisible or non-interactive subtrees
            }
            if (sprite.getLocalMatrix().inverseTransform(x, y, _scratchPoint)) {
                x = _scratchPoint.x;
                y = _scratchPoint.y;
            }
        }

        // Hit test the top director scene, if any
        var director = entity.get(Director);
        if (director != null) {
            var scene = director.topScene;
            if (scene != null) {
                var result = hitTest(scene, x, y);
                if (result != null) {
                    return result;
                }
            }
        }

        // Hit test all children, front to back
        var children = entity._internal_children;
        var ii = children.length - 1;
        while (ii >= 0) {
            var child = children[ii];
            if (child != null) {
                var result = hitTest(child, x, y);
                if (result != null) {
                    return result;
                }
            }
            --ii;
        }

        // Finally, if we got this far, hit test the actual sprite
        return (sprite != null && sprite.containsLocal(x, y)) ? sprite : null;
    }

    /**
     * Calculate the bounding box of an entity hierarchy. Returns the smallest rectangle in local
     * coordinates that fully encloses all child sprites.
     */
    public static function getBounds (entity :Entity, ?result :Rectangle) :Rectangle
    {
        if (result == null) {
            result = new Rectangle();
        }

        // The width and height of this rectangle are hijacked to store the bottom right corner
        result.set(FMath.FLOAT_MAX, FMath.FLOAT_MAX, FMath.FLOAT_MIN, FMath.FLOAT_MIN);
        getBoundsImpl(entity, null, result);

        // Convert back to a true width and height
        result.width -= result.x;
        result.height -= result.y;
        return result;
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

    /**
     * Returns the local transformation matrix, relative to the parent. This matrix may be modified
     * to position the sprite, but any changes will be invalidated when the x, y, scaleX, scaleY,
     * rotation, anchorX, or anchorY properties are updated.
     */
    public function getLocalMatrix () :Matrix
    {
        if (_flags.contains(LOCAL_MATRIX_DIRTY)) {
            _flags = _flags.remove(LOCAL_MATRIX_DIRTY);

            _localMatrix.compose(x._, y._, scaleX._, scaleY._, FMath.toRadians(rotation._));
            _localMatrix.translate(-anchorX._, -anchorY._);
        }
        return _localMatrix;
    }

    /**
     * Returns the view transformation matrix, relative to the root. Do NOT modify this matrix.
     */
    public function getViewMatrix () :Matrix
    {
        if (isViewMatrixDirty()) {
            var parentSprite = getParentSprite();
            _viewMatrix = (parentSprite != null)
                ? Matrix.multiply(parentSprite.getViewMatrix(), getLocalMatrix(), _viewMatrix)
                : getLocalMatrix().clone(_viewMatrix);

            _flags = _flags.remove(VIEW_MATRIX_DIRTY);
            if (parentSprite != null) {
                _parentViewMatrixUpdateCount = parentSprite._viewMatrixUpdateCount;
            }
            ++_viewMatrixUpdateCount;
        }
        return _viewMatrix;
    }

    /**
     * Convenience method to set the anchor position.
     * @returns This instance, for chaining.
     */
    public function setAnchor (x :Float, y :Float) :Sprite
    {
        anchorX._ = x;
        anchorY._ = y;
        return this;
    }

    /**
     * Convenience method to center the anchor.
     * @returns This instance, for chaining.
     */
    public function centerAnchor () :Sprite
    {
        anchorX._ = getNaturalWidth()/2;
        anchorY._ = getNaturalHeight()/2;
        return this;
    }

    /**
     * Convenience method to set the position.
     * @returns This instance, for chaining.
     */
    public function setXY (x :Float, y :Float) :Sprite
    {
        this.x._ = x;
        this.y._ = y;
        return this;
    }

    /**
     * Convenience method to uniformly set the scale.
     * @returns This instance, for chaining.
     */
    public function setScale (scale :Float) :Sprite
    {
        scaleX._ = scale;
        scaleY._ = scale;
        return this;
    }

    /**
     * Convenience method to set the scale.
     * @returns This instance, for chaining.
     */
    public function setScaleXY (scaleX :Float, scaleY :Float) :Sprite
    {
        this.scaleX._ = scaleX;
        this.scaleY._ = scaleY;
        return this;
    }

    /**
     * Convenience method to set pointerEnabled to false.
     * @returns This instance, for chaining.
     */
    public function disablePointer () :Sprite
    {
        pointerEnabled = false;
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

    private function isViewMatrixDirty () :Bool
    {
        if (_flags.contains(VIEW_MATRIX_DIRTY)) {
            return true;
        }
        var parentSprite = getParentSprite();
        if (parentSprite == null) {
            return false;
        }
        return _parentViewMatrixUpdateCount != parentSprite._viewMatrixUpdateCount
            || parentSprite.isViewMatrixDirty();
    }

    private function getParentSprite () :Sprite
    {
        if (owner == null) {
            return null;
        }
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

    private function getPointerDown () :Signal1<PointerEvent>
    {
        if (_internal_pointerDown == null) {
            _internal_pointerDown = new Signal1();
        }
        return _internal_pointerDown;
    }

    private function getPointerMove () :Signal1<PointerEvent>
    {
        if (_internal_pointerMove == null) {
            _internal_pointerMove = new Signal1();
        }
        return _internal_pointerMove;
    }

    private function getPointerUp () :Signal1<PointerEvent>
    {
        if (_internal_pointerUp == null) {
            _internal_pointerUp = new Signal1();
        }
        return _internal_pointerUp;
    }

    inline private function getVisible () :Bool
    {
        return _flags.contains(VISIBLE);
    }

    private function setVisible (visible :Bool) :Bool
    {
        _flags = _flags.set(VISIBLE, visible);
        return visible;
    }

    inline private function isPointerEnabled () :Bool
    {
        return _flags.contains(POINTER_ENABLED);
    }

    private function setPointerEnabled (pointerEnabled :Bool) :Bool
    {
        _flags = _flags.set(POINTER_ENABLED, pointerEnabled);
        return pointerEnabled;
    }

    private static function getBoundsImpl (entity :Entity, matrix :Matrix, result :Rectangle)
    {
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            matrix = (matrix != null)
                ? Matrix.multiply(matrix, sprite.getLocalMatrix()) // Allocation!
                : sprite.getLocalMatrix();

            // Extend the rectangle out to fit this sprite
            var width = sprite.getNaturalWidth(), height = sprite.getNaturalHeight();
            extendRect(matrix, 0, 0, result);
            extendRect(matrix, width, 0, result);
            extendRect(matrix, width, height, result);
            extendRect(matrix, 0, height, result);
        }

        // Recurse into all visible director scenes
        var director = entity.get(Director);
        if (director != null) {
            var scenes = director.visibleScenes;
            var ii = 0, ll = scenes.length;
            while (ii < ll) {
                getBoundsImpl(scenes[ii], matrix, result);
                ++ii;
            }
        }

        // Recurse into all children
        var children = entity._internal_children;
        var ii = 0, ll = children.length;
        while (ii < ll) {
            var child = children[ii];
            if (child != null) {
                getBoundsImpl(child, matrix, result);
            }
            ++ii;
        }
    }

    private static function extendRect (matrix :Matrix, x :Float, y :Float, rect :Rectangle)
    {
        var p = matrix.transform(x, y, _scratchPoint);
        x = p.x;
        y = p.y;

        // The width and height of the rectangle are treated like the bottom right point, rather
        // than a true width and height offset
        if (x < rect.x) rect.x = x;
        if (y < rect.y) rect.y = y;
        if (x > rect.width) rect.width = x;
        if (y > rect.height) rect.height = y;
    }

    private static var _scratchPoint = new Point();

    // Various flags used by Sprite and subclasses
    private static inline var VISIBLE = 1 << 0;
    private static inline var POINTER_ENABLED = 1 << 1;
    private static inline var LOCAL_MATRIX_DIRTY = 1 << 2;
    private static inline var VIEW_MATRIX_DIRTY = 1 << 3;
    private static inline var MOVIESPRITE_PAUSED = 1 << 4;
    private static inline var TEXTSPRITE_DIRTY = 1 << 5;

    private var _flags :Int;

    private var _localMatrix :Matrix;

    private var _viewMatrix :Matrix = null;
    private var _viewMatrixUpdateCount :Int = 0;
    private var _parentViewMatrixUpdateCount :Int = 0;

    /** @private */ public var _internal_pointerDown :Signal1<PointerEvent>;
    /** @private */ public var _internal_pointerMove :Signal1<PointerEvent>;
    /** @private */ public var _internal_pointerUp :Signal1<PointerEvent>;
}
