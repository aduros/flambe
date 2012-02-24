//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Library;

class MovieSprite extends Sprite
{
    public function new (lib :Library)
    {
        super();

        var frames = 0;
        _layers = [];
        for (layer in lib.layers) {
            _layers.push(new MovieLayerSprite(layer));
            frames = cast Math.max(layer.frames, frames);
        }

        _duration = frames / 30;
        _goingToFrame = false;
        goto(0, true, false);
    }

    override public function onAdded ()
    {
        for (layer in _layers) {
            owner.addChild(new Entity().add(layer));
        }
    }

    override public function onUpdate (dt :Int)
    {
        super.onUpdate(dt);
    }

    private function goto (newFrame :Int, fromSkip :Bool, overDuration :Bool)
    {
        if (_goingToFrame) {
            _pendingFrame = newFrame;
            return;
        }
        _goingToFrame = true;

        var differentFrame = newFrame != _frame;
        var wrapped = newFrame < _frame;
        if (differentFrame) {
            // if (wrapped) {
            //     for (layer in _layers) {
            //         layer.changedKeyframe = true;
            //         layer.keyframeIdx = 0;
            //     }
            // }
            for (layer in _layers) {
                layer.composeFrame(newFrame);
            }
        }

        _goingToFrame = false;
        if (_pendingFrame != -1) {
            newFrame = _pendingFrame;
            _pendingFrame = -1;
            goto(newFrame, true, false);
        }
    }

    private var _lib :Library;

    private var _layers :Array<MovieLayerSprite>;
    private var _duration :Float;

    private var _frame :Int;
    private var _goingToFrame :Bool;
    private var _pendingFrame :Int;
}
