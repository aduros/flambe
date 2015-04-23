package tintShaderExample;

import flambe.platform.Effect;

#if flash
    import hxsl.Shader;
#else
    import flambe.platform.shader.ShaderGL;
    import js.html.webgl.RenderingContext;
#end

import tintShaderExample.TintShader;

/**
 * Red Tint Example Effect
 */
class TintEffect implements Effect
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
        this.shader = new TintShader();
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
        this.shader = new TintShader(gl);
    }
#end
}
