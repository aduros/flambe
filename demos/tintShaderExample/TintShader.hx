package tintShaderExample;

#if flash
    /** HXSL Stage3D Shader Implementation */
    import flambe.platform.shader.ShaderHXSL;
    import flash.display3D.textures.TextureBase;
    import hxsl.Shader;

    class TintShader extends Shader implements ShaderHXSL
    {
        public var shaderConst :ShaderConst;
        static var SRC = {
            var input :{
                pos :Float2,
                uv :Float2,
                alpha :Float,
            };

            var _uv :Float2;
            var _alpha :Float;

            function vertex () {
                _uv = input.uv;
                _alpha = input.alpha;
                out = input.pos.xyzw;
            }

            function fragment (texture :Texture, tintColor :Float4)
            {
                var color = texture.get(_uv, clamp) * _alpha;
                out = color * tintColor;
            }
        }

        public function new()
        {
            super();

            shaderConst = new ShaderConst();
            shaderConst.linkUniformf("tintColor", tintColor);
        }

        public function setTexture(texture :TextureBase) :Void
        {
            this.texture = texture;
        }
    }
#else
    /** WebGL HTML Shader Implementation */
    import js.html.*;
    import js.html.webgl.*;
    import js.html.webgl.RenderingContext;

    import flambe.platform.shader.ShaderGL;
    import flambe.platform.html.WebGLTexture;

    class TintShader extends ShaderGL
    {
        public function new (gl :RenderingContext)
        {
            super(gl,
            [ // Vertex shader
                "attribute highp vec2 a_pos;",
                "attribute mediump vec2 a_uv;",
                "attribute lowp float a_alpha;",

                "varying mediump vec2 v_uv;",
                "varying lowp float v_alpha;",

                "void main (void) {",
                    "v_uv = a_uv;",
                    "v_alpha = a_alpha;",
                    "gl_Position = vec4(a_pos, 0, 1);",
                "}",
            ].join("\n"),

            [ // Fragment shader
                "varying mediump vec2 v_uv;",
                "varying lowp float v_alpha;",

                "uniform mediump vec4 tintColor;",
                "uniform lowp sampler2D u_texture;",

                "void main (void) {",
                    "gl_FragColor = texture2D(u_texture, v_uv) * v_alpha;",
                    "gl_FragColor *= tintColor;",
                "}",
            ].join("\n"));

            a_pos = getAttribLocation("a_pos");
            a_uv = getAttribLocation("a_uv");
            a_alpha = getAttribLocation("a_alpha");

            u_texture = getUniformLocation("u_texture");
            setTexture(0);
        }

        public function setTexture (unit :Int)
        {
            _gl.uniform1i(u_texture, unit);
        }

        override public function prepare ()
        {
            _gl.enableVertexAttribArray(a_pos);
            _gl.enableVertexAttribArray(a_uv);
            _gl.enableVertexAttribArray(a_alpha);

            var bytesPerFloat = Float32Array.BYTES_PER_ELEMENT;
            var stride = 5*bytesPerFloat;
            _gl.vertexAttribPointer(a_pos, 2, GL.FLOAT, false, stride, 0*bytesPerFloat);
            _gl.vertexAttribPointer(a_uv, 2, GL.FLOAT, false, stride, 2*bytesPerFloat);
            _gl.vertexAttribPointer(a_alpha, 1, GL.FLOAT, false, stride, 4*bytesPerFloat);
        }

        private var a_pos :Int;
        private var a_uv :Int;
        private var a_alpha :Int;

        private var u_texture :UniformLocation;
    }
#end