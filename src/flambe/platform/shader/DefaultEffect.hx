//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import flambe.platform.Effect;

#if flash
    import hxsl.Shader;
    import flambe.platform.shader.DrawTexture;
#else
    import js.html.webgl.RenderingContext;
    import flambe.platform.shader.ShaderGL;
    import flambe.platform.shader.DrawTextureGL;
#end

/**
 * Default effect containing shaders for both hxsl and WebGL
 */
class DefaultEffect implements Effect
{
#if flash
    public var shader:Shader;

    public function new()
    {
        shader = null;
    }

    public function instantiate() :Void
    {
        this.shader = new DrawTexture();
    }

#else
    public var shader:ShaderGL;

    public function new()
    {
        shader = null;
    }

    public function instantiate(gl :RenderingContext) :Void
    {
        this.shader = new DrawTextureGL(gl);
    }
#end
}
