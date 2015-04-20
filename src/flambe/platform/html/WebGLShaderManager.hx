//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.webgl.RenderingContext;
import flambe.platform.shader.ShaderGL;
import flambe.platform.shader.DrawTextureGL;
import flambe.platform.shader.DrawPatternGL;
import flambe.platform.shader.FillRectGL;

/**
 * Shader manager for HTML WebGL shaders
 */
class WebGLShaderManager
{
// New operator overload
    public function new(gl :RenderingContext)
    {
        _shaderMap = new Map<String, ShaderGL>();
        _shaderMap.set("drawTexture", new DrawTextureGL(gl));
        _shaderMap.set("drawPattern", new DrawPatternGL(gl));
        _shaderMap.set("fillRect", new FillRectGL(gl));
    }

    public function getShader(key :String):ShaderGL
    {
        return _shaderMap.get(key);
    }

    public function addShader(key :String, shader :ShaderGL):Void
    {
        _shaderMap.set(key, shader);
    }

    private var _shaderMap:Map<String, ShaderGL>;
}
