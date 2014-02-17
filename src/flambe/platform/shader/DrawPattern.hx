//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import hxsl.Shader;

/**
 * Draws a repeating texture.
 */
class DrawPattern extends Shader
{
    static var SRC = {
        var input :{
            pos :Float2,
            uv :Float2,
            alpha :Float,
        };

        var _uv :Float2;
        var _alpha :Float;

        function vertex () {
            _uv = input.uv;
            _alpha = input.alpha;
            out = input.pos.xyzw;
        }

        function fragment (texture :Texture, region :Float4) {
            out = texture.get(region.xy + _uv%region.zw, clamp) * _alpha;
        }
    }
}
