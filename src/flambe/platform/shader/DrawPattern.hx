//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import format.hxsl.Shader;

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

        function vertex (model :Matrix, proj :Matrix) {
            _uv = uv;
            _alpha = alpha;
            out = pos.xyzw * model * proj;
        }

        function fragment (texture :Texture, maxUV :Float2) {
            var color = texture.get(_uv % maxUV);
            color *= _alpha;
            out = color;
        }
    }
}
