//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import flambe.platform.html.WebGLTypes;

class DrawImageGL extends ShaderGL
{
    public function new (gl :RenderingContext)
    {
        super(gl,
        [ // Vertex shader
            "attribute vec2 a_pos;",

            "void main (void) {",
                "gl_Position = vec4(a_pos, 0, 1);",
            "}",
        ].join("\n"),

        [ // Fragment shader
            "uniform vec3 u_color;",

            "void main (void) {",
                "gl_FragColor = vec4(u_color, 1);",
            "}",
        ].join("\n"));

        a_pos = getAttribLocation("a_pos");
        u_color = getUniformLocation("u_color");
    }

    public function setUniforms (r :Float, g :Float, b :Float)
    {
        _gl.uniform3f(u_color, r, g, b);
    }

    override public function enableVertexArrays ()
    {
        _gl.enableVertexAttribArray(a_pos);
        _gl.vertexAttribPointer(a_pos, 2, _gl.FLOAT, false, 0, 0);
    }

    override public function disableVertexArrays ()
    {
        _gl.disableVertexAttribArray(a_pos);
    }

    private var a_pos :Int;
    private var u_color :UniformLocation;
}
