//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.animation.Ease;
import flambe.display.Sprite;

/**
 * Slides the old scene off the stage, and the new scene into its place.
 */
class SlideTransition extends TweenTransition
{
    public function new (duration :Float, ?ease :EaseFunction)
    {
        super(duration, ease);
    }

    /**
     * Slides the transition upwards.
     * @returns This instance, for chaining.
     */
    public function up ()
    {
        _direction = UP;
        return this;
    }

    /**
     * Slides the transition downwards.
     * @returns This instance, for chaining.
     */
    public function down ()
    {
        _direction = DOWN;
        return this;
    }

    /**
     * Slides the transition to the left.
     * @returns This instance, for chaining.
     */
    public function left ()
    {
        _direction = LEFT;
        return this;
    }

    /**
     * Slides the transition to the right.
     * @returns This instance, for chaining.
     */
    public function right ()
    {
        _direction = RIGHT;
        return this;
    }

    override public function init (director :Director, from :Entity, to :Entity)
    {
        super.init(director, from, to);

        switch (_direction) {
        case UP:
            _x = 0; _y = -_director.height;
        case DOWN:
            _x = 0; _y = _director.height;
        case LEFT:
            _x = -_director.width; _y = 0;
        case RIGHT:
            _x = _director.width; _y = 0;
        }

        var sprite = _from.get(Sprite);
        if (sprite == null) {
            _from.add(sprite = new Sprite());
        }
        sprite.setXY(0, 0);

        var sprite = _to.get(Sprite);
        if (sprite == null) {
            _to.add(sprite = new Sprite());
        }
        sprite.setXY(-_x, -_y);
    }

    override public function update (dt :Float) :Bool
    {
        var done = super.update(dt);
        _from.get(Sprite).setXY(interp(0, _x), interp(0, _y));
        _to.get(Sprite).setXY(interp(-_x, 0), interp(-_y, 0));
        return done;
    }

    override public function complete ()
    {
        _from.get(Sprite).setXY(0, 0);
        _to.get(Sprite).setXY(0, 0);
    }

    private static inline var UP = 0;
    private static inline var DOWN = 1;
    private static inline var LEFT = 2;
    private static inline var RIGHT = 3;

    private var _direction :Int = LEFT;

    // Where the old scene should end up
    private var _x :Float;
    private var _y :Float;
}
