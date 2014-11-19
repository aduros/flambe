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
			#if flambe_stage3d_force_nearest
				// region is weirdly ordered to workaround a Windows bug
				out = texture.get(region.zw + _uv % region.xy, clamp, nearest) * _alpha;
			#else
				// region is weirdly ordered to workaround a Windows bug
				out = texture.get(region.zw + _uv % region.xy, clamp) * _alpha;
			#end
        }
    }
}
