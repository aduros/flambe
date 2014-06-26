//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import hxsl.Shader;

/**
 * Shader that draws textured triangles with a given alpha.
 */
class DrawTexture extends Shader
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

        function fragment (texture :Texture) {
            out = texture.get(_uv, clamp) * _alpha;
        }
    }
}
