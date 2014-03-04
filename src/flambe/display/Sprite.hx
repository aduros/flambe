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
import flambe.util.SignalConnection;
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
     * The scissor rectangle used for clipping/masking, in the local coordinate system. The scissor
     * rectangle affects both rendering and hit testing, and applies to this sprite and all
     * children. Rectangles with negative width or height are OK.
     *
     * __WARNING__: When using scissor testing, this sprite (and its parents) must not be rotated.
     * The scissor rectangle must be axis-aligned when converted to screen coordinates.
     */
    public var scissor :Rectangle = null;

    /**
     * Whether this sprite should be drawn. Invisible sprites do not receive pointer events.
     */
    public var visible (get, set) :Bool;

    /**
     * Whether this sprite's position will be rounded to the nearest whole pixel when rendering, for
     * crisper images. Defaults to true. This can be disabled for smoother animation, at the risk of
     * fuzziness when an image lies on a subpixel.
     */
    public var pixelSnapping (get, set) :Bool;

    /**
     * Emitted when the pointer is pressed down over this sprite.
     */
    public var pointerDown (get, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is moved over this sprite.
     */
    public var pointerMove (get, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is raised over this sprite.
     */
    public var pointerUp (get, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is moved inside of this sprite.
     */
    public var pointerIn (get, null) :Signal1<PointerEvent>;

    /**
     * Emitted when the pointer is moved outside of this sprite. If the pointer is a touch, also
     * emitted when the touch is lifted from this sprite.
     */
    public var pointerOut (get, null) :Signal1<PointerEvent>;

    /**
     * Whether this sprite or any children should receive pointer events. Defaults to true.
     */
    public var pointerEnabled (get, set) :Bool;

    public function new ()
    {
        _flags = VISIBLE | POINTER_ENABLED | VIEW_MATRIX_DIRTY | PIXEL_SNAPPING;
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

            var scissor = sprite.scissor;
            if (scissor != null && !scissor.contains(x, y)) {
                return null; // Prune if outside the scissor rectangle
            }
        }

        // Hit test all children, front to back
        var result = hitTestBackwards(entity.firstChild, x, y);
        if (result != null) {
            return result;
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
     * Renders an entity hierarchy to the given Graphics.
     */
    public static function render (entity :Entity, g :Graphics)
    {
        // Render this entity's sprite
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            var alpha = sprite.alpha._;
            if (!sprite.visible || alpha <= 0) {
                return; // Prune traversal, this sprite and all children are invisible
            }

            g.save();
            if (alpha < 1) {
                g.multiplyAlpha(alpha);
            }
            if (sprite.blendMode != null) {
                g.setBlendMode(sprite.blendMode);
            }
            var matrix = sprite.getLocalMatrix();

            var m02 = matrix.m02;
            var m12 = matrix.m12;
            if (sprite.pixelSnapping) {
                // Snap the translation to the nearest whole pixel
                m02 = Math.round(m02);
                m12 = Math.round(m12);
            }
            g.transform(matrix.m00, matrix.m10, matrix.m01, matrix.m11, m02, m12);

            var scissor = sprite.scissor;
            if (scissor != null) {
                g.applyScissor(scissor.x, scissor.y, scissor.width, scissor.height);
            }

            sprite.draw(g);
        }

        // Render any partially occluded director scenes
        var director = entity.get(Director);
        if (director != null) {
            var scenes = director.occludedScenes;
            for (scene in scenes) {
                render(scene, g);
            }
        }

        // Render all children
        var p = entity.firstChild;
        while (p != null) {
            var next = p.next;
            render(p, g);
            p = next;
        }

        // If save() was called, unwind it
        if (sprite != null) {
            g.restore();
        }
    }

    /**
     * The "natural" width of this sprite, without any transformations being applied. Used for hit
     * testing. This does not consider child sprites, use Sprite.getBounds for that.
     */
    public function getNaturalWidth () :Float
    {
        return 0;
    }

    /**
     * The "natural" height of this sprite, without any transformations being applied. Used for hit
     * testing. This does not consider child sprites, use Sprite.getBounds for that.
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
     * Chainable convenience method to set the anchor position.
     * @returns This instance, for chaining.
     */
    public function setAnchor (x :Float, y :Float) :Sprite
    {
        anchorX._ = x;
        anchorY._ = y;
        return this;
    }

    /**
     * Chainable convenience method to center the anchor using the natural width and height.
     * @returns This instance, for chaining.
     */
    public function centerAnchor () :Sprite
    {
        anchorX._ = getNaturalWidth()/2;
        anchorY._ = getNaturalHeight()/2;
        return this;
    }

    /**
     * Chainable convenience method to set the position.
     * @returns This instance, for chaining.
     */
    public function setXY (x :Float, y :Float) :Sprite
    {
        this.x._ = x;
        this.y._ = y;
        return this;
    }
	
    /**
     * Chainable convenience method to set the alpha.
     * @returns This instance, for chaining.
     */
    public function setAlpha (alpha :Float) :Sprite
    {
        this.alpha._ = alpha;
        return this;
    }
	
    /**
     * Chainable convenience method to set the rotation.
     * @returns This instance, for chaining.
     */
    public function setRotation (rotation :Float) :Sprite
    {
        this.rotation._ = rotation;
        return this;
    }

    /**
     * Chainable convenience method to uniformly set the scale.
     * @returns This instance, for chaining.
     */
    public function setScale (scale :Float) :Sprite
    {
        scaleX._ = scale;
        scaleY._ = scale;
        return this;
    }

    /**
     * Chainable convenience method to set the scale.
     * @returns This instance, for chaining.
     */
    public function setScaleXY (scaleX :Float, scaleY :Float) :Sprite
    {
        this.scaleX._ = scaleX;
        this.scaleY._ = scaleY;
        return this;
    }

    /**
     * Chainable convenience method to set the blendMode.
     * @returns This instance, for chaining.
     */
    public function setBlendMode (blendMode :BlendMode) :Sprite
    {
        this.blendMode = blendMode;
        return this;
    }

    /**
     * Chainable convenience method to set pointerEnabled to false.
     * @returns This instance, for chaining.
     */
    public function disablePointer () :Sprite
    {
        pointerEnabled = false;
        return this;
    }

    /**
     * Chainable convenience method to set pixelSnapping to false.
     * @returns This instance, for chaining.
     */
    public function disablePixelSnapping () :Sprite
    {
        pixelSnapping = false;
        return this;
    }

    override public function onAdded ()
    {
        if (_flags.contains(HOVERING)) {
            connectHover();
        }
    }

    override public function onRemoved ()
    {
        if (_hoverConnection != null) {
            _hoverConnection.dispose();
            _hoverConnection = null;
        }
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
     * Draws this sprite to the given Graphics.
     */
    public function draw (g :Graphics)
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

    private function get_pointerDown () :Signal1<PointerEvent>
    {
        if (_pointerDown == null) {
            _pointerDown = new Signal1();
        }
        return _pointerDown;
    }

    private function get_pointerMove () :Signal1<PointerEvent>
    {
        if (_pointerMove == null) {
            _pointerMove = new Signal1();
        }
        return _pointerMove;
    }

    private function get_pointerUp () :Signal1<PointerEvent>
    {
        if (_pointerUp == null) {
            _pointerUp = new Signal1();
        }
        return _pointerUp;
    }

    private function get_pointerIn () :Signal1<PointerEvent>
    {
        if (_pointerIn == null) {
            _pointerIn = new Signal1();
        }
        return _pointerIn;
    }

    private function get_pointerOut () :Signal1<PointerEvent>
    {
        if (_pointerOut == null) {
            _pointerOut = new Signal1();
        }
        return _pointerOut;
    }

    private function connectHover ()
    {
        if (_hoverConnection != null) {
            return;
        }
        _hoverConnection = System.pointer.move.connect(function (event) {
            // Return early if this sprite was in the event chain
            var hit = event.hit;
            while (hit != null) {
                if (hit == this) {
                    return;
                }
                hit = hit.getParentSprite();
            }

            // This sprite is not under the pointer
            if (_pointerOut != null && _flags.contains(HOVERING)) {
                _pointerOut.emit(event);
            }
            _flags = _flags.remove(HOVERING);
            _hoverConnection.dispose();
            _hoverConnection = null;
        });
    }

    inline private function get_visible () :Bool
    {
        return _flags.contains(VISIBLE);
    }

    private function set_visible (visible :Bool) :Bool
    {
        _flags = _flags.set(VISIBLE, visible);
        return visible;
    }

    inline private function get_pointerEnabled () :Bool
    {
        return _flags.contains(POINTER_ENABLED);
    }

    private function set_pointerEnabled (pointerEnabled :Bool) :Bool
    {
        _flags = _flags.set(POINTER_ENABLED, pointerEnabled);
        return pointerEnabled;
    }

    inline private function get_pixelSnapping () :Bool
    {
        return _flags.contains(PIXEL_SNAPPING);
    }

    private function set_pixelSnapping (pixelSnapping :Bool) :Bool
    {
        _flags = _flags.set(PIXEL_SNAPPING, pixelSnapping);
        return pixelSnapping;
    }

    @:allow(flambe) function onPointerDown (event :PointerEvent)
    {
        onHover(event);
        if (_pointerDown != null) {
            _pointerDown.emit(event);
        }
    }

    @:allow(flambe) function onPointerMove (event :PointerEvent)
    {
        onHover(event);
        if (_pointerMove != null) {
            _pointerMove.emit(event);
        }
    }

    private function onHover (event :PointerEvent)
    {
        if (_flags.contains(HOVERING)) {
            return; // Already hovering
        }
        _flags = _flags.add(HOVERING);

        // Notify listeners and connect the hover-out listener
        if ((_pointerIn != null || _pointerOut != null)) {
            if (_pointerIn != null) {
                _pointerIn.emit(event);
            }
            connectHover();
        }
    }

    @:allow(flambe) function onPointerUp (event :PointerEvent)
    {
        switch (event.source) {
        case Touch(point):
            if (_pointerOut != null && _flags.contains(HOVERING)) {
                _pointerOut.emit(event);
            }
            _flags = _flags.remove(HOVERING);
            if (_hoverConnection != null) {
                _hoverConnection.dispose();
                _hoverConnection = null;
            }
        default:
        }

        if (_pointerUp != null) {
            _pointerUp.emit(event);
        }
    }

    private static function hitTestBackwards (entity :Entity, x :Float, y :Float) :Sprite
    {
        if (entity != null) {
            var result = hitTestBackwards(entity.next, x, y);
            return (result != null) ? result : hitTest(entity, x, y);
        }
        return null;
    }

    private static function getBoundsImpl (entity :Entity, matrix :Matrix, result :Rectangle)
    {
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            matrix = (matrix != null)
                ? Matrix.multiply(matrix, sprite.getLocalMatrix()) // Allocation!
                : sprite.getLocalMatrix();

            var x1 = 0.0, y1 = 0.0;
            var x2 = sprite.getNaturalWidth(), y2 = sprite.getNaturalHeight();

            // Intersecting scissor rectangles are too tricky for bounds calculation, ignore it for
            // now...
            // var scissor = sprite.scissor;
            // if (scissor != null) {
            //     x1 = FMath.max(x1, scissor.x);
            //     y1 = FMath.max(y1, scissor.y);
            //     x2 = FMath.min(x2, scissor.x + scissor.width);
            //     y2 = FMath.min(y2, scissor.y + scissor.height);
            // }

            // Extend the rectangle out to fit this sprite
            if (x2 > x1 && y2 > y1) {
                extendRect(matrix, x1, y1, result);
                extendRect(matrix, x2, y1, result);
                extendRect(matrix, x2, y2, result);
                extendRect(matrix, x1, y2, result);
            }
        }

        // Recurse into partially occluded director scenes
        var director = entity.get(Director);
        if (director != null) {
            var scenes = director.occludedScenes;
            var ii = 0, ll = scenes.length;
            while (ii < ll) {
                getBoundsImpl(scenes[ii], matrix, result);
                ++ii;
            }
        }

        // Recurse into all children
        var p = entity.firstChild;
        while (p != null) {
            var next = p.next;
            getBoundsImpl(p, matrix, result);
            p = next;
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
    private static inline var MOVIESPRITE_SKIP_NEXT = 1 << 5;
    private static inline var TEXTSPRITE_DIRTY = 1 << 6;
    private static inline var PIXEL_SNAPPING = 1 << 7;
    private static inline var HOVERING = 1 << 8;

    private var _flags :Int;

    private var _localMatrix :Matrix;

    private var _viewMatrix :Matrix = null;
    private var _viewMatrixUpdateCount :Int = 0;
    private var _parentViewMatrixUpdateCount :Int = 0;

    private var _pointerDown :Signal1<PointerEvent>;
    private var _pointerMove :Signal1<PointerEvent>;
    private var _pointerUp :Signal1<PointerEvent>;

    private var _pointerIn :Signal1<PointerEvent>;
    private var _pointerOut :Signal1<PointerEvent>;
    private var _hoverConnection :SignalConnection;
}
