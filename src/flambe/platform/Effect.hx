//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

#if flash
    import hxsl.Shader;
#else
    import js.html.webgl.RenderingContext;
    import flambe.platform.shader.ShaderGL;
#end

/**
 * Effect, an abstraction of the platform specific shaders
 */
interface Effect
{
#if flash
    public var shader:Shader;

    public function instantiate() :Void;
#else
    public var shader:ShaderGL;

    public function instantiate(gl :RenderingContext) :Void;
#end
}
