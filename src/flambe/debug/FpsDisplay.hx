//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.debug;

import flambe.display.TextSprite;

/**
 * A component that uses its entity's TextSprite to display an FPS log.
 */
class FpsDisplay
    extends Component
{
    public function new ()
    {
        reset();
    }

    override public function onUpdate (dt :Float)
    {
        ++_fpsFrames;
        _fpsTime += dt;
        if (_fpsTime > 1) {
            var fps = _fpsFrames/_fpsTime;
            var text = "FPS: " + Std.int(fps*100) / 100;

            // Use our owner's TextSprite if available, otherwise just log it
            var sprite = owner.get(TextSprite);
            if (sprite != null) {
                sprite.text = text;
            } else {
                Log.info(text);
            }

            reset();
        }
    }

    private function reset ()
    {
        _fpsTime = _fpsFrames = 0;
    }

    private var _fpsFrames :Int;
    private var _fpsTime :Float;
}
