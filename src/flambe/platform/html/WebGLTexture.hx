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
    	trace("new WebGLTexture");
        super(root, width, height);
    }

    override public function split (tilesWide :Int, tilesHigh :Int = 1) :Array<SubTexture>
    {
        var tiles = [];

        var tileWidth = Std.int(_width / tilesWide);
        var tileHeight = Std.int(_height / tilesHigh);

        for (y in 0...tilesHigh) {
            for (x in 0...tilesWide) {
                tiles.push(subTexture(x*tileWidth, y*tileHeight, tileWidth, tileHeight));
            }
        }
        return tiles;
    }

    override public function subTexture (x :Int, y :Int, width :Int, height :Int) :SubTexture
    {
        var sub :BasicTexture<WebGLTextureRoot>;

    #if flambe_webgl_enable_mipmapping
		// 1 px textures cause weird DrawPattern sampling on some drivers
        var pow2Width = FMath.max(2, MathUtil.nextPowerOfTwo(width));
        var pow2Height = FMath.max(2, MathUtil.nextPowerOfTwo(height));
    	trace("WebGLTexture: subTexture POW2: " + pow2Width + " height: " + pow2Height);
    	sub = cast root.createTexture(pow2Width, pow2Height);
    #else
    	sub = cast root.createTexture(width, height);
    #end
    	trace("WebGLTexture: subTexture " + sub.width + " height: " + sub.height);
        sub._parent = this;
        sub._x = x;
        sub._y = y;
        sub.rootX = rootX + x;
        sub.rootY = rootY + y;
        return sub;
    }


}
