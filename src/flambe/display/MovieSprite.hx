//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Library;

class MovieSprite extends Sprite
{
    public function new (movie :MovieSymbol)
    {
        super();

        var frames = 0;
        _layers = [];

        for (layer in movie.layers) {
            _layers.push(new LayerSprite(layer));
            frames = cast Math.max(layer.frames, frames);
        }

        _duration = 1000/30 *frames;
        _goingToFrame = false;
        _frame = 0;
        goto(1, true, false);
    }

    override public function onAdded ()
    {
        for (layer in _layers) {
            owner.addChild(new Entity().add(layer));
        }
        _elapsed = 0;
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);

        _elapsed += dt;
        if (_elapsed > _duration) {
            _elapsed = _elapsed % _duration;
        }

        var newFrame = Std.int(_elapsed * 30/1000);
        var overDuration = dt >= _duration;

        // TODO(bruno): Handle _stopFrame?

        goto(newFrame, false, overDuration);
    }

    private function goto (newFrame :Int, fromSkip :Bool, overDuration :Bool)
    {
        if (_goingToFrame) {
            _pendingFrame = newFrame;
            return;
        }
        _goingToFrame = true; // TODO(bruno): Why is this necessary?

        var differentFrame = newFrame != _frame;
        var wrapped = newFrame < _frame;
        if (differentFrame) {
            if (wrapped) {
                for (layer in _layers) {
                    layer.changedKeyframe = true;
                    layer.lastFrame = 0;
                }
            }
            for (layer in _layers) {
                layer.composeFrame(newFrame);
            }
        }

        var oldFrame = _frame;
        _frame = newFrame;

        _goingToFrame = false;
        if (_pendingFrame != -1) {
            newFrame = _pendingFrame;
            _pendingFrame = -1;
            goto(newFrame, true, false);
        }
    }

    private var _lib :Library;

    private var _layers :Array<LayerSprite>;
    private var _duration :Float;
    private var _elapsed :Float;

    private var _frame :Int;
    private var _goingToFrame :Bool;
    private var _pendingFrame :Int;
}
