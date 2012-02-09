//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import format.hxsl.Shader;

/**
 * Shader that draws textured triangles with a given alpha.
 */
class DrawImage extends Shader
{
    static var SRC = {
        var input :{
            pos :Float2,
            uv :Float2,
        };

        var tuv :Float2;

        function vertex (model :Matrix, proj :Matrix) {
            out = pos.xyzw * model * proj;
            tuv = uv;
        }

        function fragment (texture :Texture, alpha :Float) {
            var color = texture.get(tuv);
            color.a *= alpha;
            out = color;
        }
    }
}
