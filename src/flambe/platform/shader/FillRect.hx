//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import format.hxsl.Shader;

/**
 * Shader that draws solid colored triangles.
 */
class FillRect extends Shader
{
    static var SRC = {
        var input :{
            pos :Float2,
        };

        function vertex (model :Matrix, proj :Matrix) {
            out = pos.xyzw * model * proj;
        }

        function fragment (color :Float4) {
            out = color;
        }
    }
}
