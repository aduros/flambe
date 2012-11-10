//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.animation.Ease;
import flambe.display.Sprite;

/**
 * Fades the new scene in front of the old scene.
 */
class FadeTransition extends TweenTransition
{
    public function new (duration :Float, ?ease :EaseFunction)
    {
        super(duration, ease);
    }

    override public function init (director :Director, from :Entity, to :Entity)
    {
        super.init(director, from, to);
        var sprite = _to.get(Sprite);
        if (sprite == null) {
            _to.add(sprite = new Sprite());
        }
        sprite.alpha._ = 0;
    }

    override public function update (dt :Float) :Bool
    {
        var done = super.update(dt);
        _to.get(Sprite).alpha._ = interp(0, 1);
        return done;
    }

    override public function complete ()
    {
        _to.get(Sprite).alpha._ = 1;
    }
}
