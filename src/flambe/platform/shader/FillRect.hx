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
            color: Float4,
        };

        var _color :Float4;

        function vertex () {
            _color = color;
            out = pos.xyzw;
        }

        function fragment () {
            out = _color;
        }
    }
}
