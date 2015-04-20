//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import hxsl.Shader;
import flambe.platform.shader.DrawTexture;
import flambe.platform.shader.DrawPattern;
import flambe.platform.shader.FillRect;

/**
 * Shader manager for Stage3D hxsl shaders
 */
class Stage3DShaderManager
{
    // New operator overload
    public function new()
    {
        _shaderMap = new Map<String, Shader>();
        _shaderMap.set("drawTexture", new DrawTexture());
        _shaderMap.set("drawPattern", new DrawPattern());
        _shaderMap.set("fillRect", new FillRect());
    }

    public function getShader(key :String):Shader
    {
        return _shaderMap.get(key);
    }

    public function addShader(key :String, shader :Shader):Void
    {
        _shaderMap.set(key, shader);
    }

    private var _shaderMap:Map<String, Shader>;
}
