//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.animation.Ease;

/**
 * A helper extended by transitions that tween between two states.
 */
class TweenTransition extends Transition
{
    private function new (duration :Float, ?ease :EaseFunction)
    {
        _duration = duration;
        _ease = (ease != null) ? ease : Ease.linear;
    }

    override public function init (director :Director, from :Entity, to :Entity)
    {
        super.init(director, from, to);
        _elapsed = 0;
    }

    override public function update (dt :Float) :Bool
    {
        _elapsed += dt;
        return _elapsed >= _duration;
    }

    private function interp (from :Float, to :Float) :Float
    {
        return from + (to-from) * _ease(_elapsed/_duration);
    }

    private var _ease :EaseFunction;
    private var _elapsed :Float;
    private var _duration :Float;
}
