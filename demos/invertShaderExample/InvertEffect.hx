package invertShaderExample;

import flambe.platform.Effect;

#if flash
    import hxsl.Shader;
#else
    import flambe.platform.shader.ShaderGL;
    import js.html.webgl.RenderingContext;
#end

import invertShaderExample.InvertShader;

/**
 * Invert Example Effect
 */
class InvertEffect implements Effect
{
#if flash
    /**This is the shader definition for the flash platform */
    public var shader:Shader;

    public function new()
    {
        shader = null;
    }

    public function instantiate() :Void
    {
        this.shader = new InvertShader();
    }
#else
    /**This is the shader definition for the html (WebGL) platform */
    public var shader:ShaderGL;

    public function new()
    {
        shader = null;
    }

    public function instantiate(gl :RenderingContext) :Void
    {
        this.shader = new InvertShader(gl);
    }
#end
}
