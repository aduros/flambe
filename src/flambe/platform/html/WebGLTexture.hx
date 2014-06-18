//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.display.SubTexture;
import flambe.math.FMath;
import flambe.platform.html.WebGLTextureRoot;
import flambe.platform.MathUtil;

class WebGLTexture extends BasicTexture<WebGLTextureRoot>
{
    public function new (root :WebGLTextureRoot, width :Int, height :Int)
    {
        super(root, width, height);
    }
}
