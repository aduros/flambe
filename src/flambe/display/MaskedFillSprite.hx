//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.util.Value;

/**
 * A sprite that displays the given mask texture in the given color.
 */
class MaskedFillSprite extends ImageSprite
{
    public function new (color :Int, mask :Texture)
    {
        var texture = System.createTexture(mask.width, mask.height);
        texture.graphics.fillRect(color, 0, 0, mask.width, mask.height);
        texture.graphics.setBlendMode(Mask);
        texture.graphics.drawImage(mask, 0, 0);

        super(texture);
    }
}