//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

// A bunch of placeholder typedefs that will make it easier to later transition to the proper
// externs included in Haxe 3

typedef ActiveInfo = Dynamic;
typedef Buffer = Dynamic;
typedef CompressedTextureS3TC = Dynamic;
typedef ContextAttributes = Dynamic;
typedef ContextEvent = Dynamic;
typedef DebugRendererInfo = Dynamic;
typedef DebugShaders = Dynamic;
typedef DepthTexture = Dynamic;
typedef EXTTextureFilterAnisotropic = Dynamic;
typedef Framebuffer = Dynamic;
typedef LoseContext = Dynamic;
typedef OESElementIndexUint = Dynamic;
typedef OESStandardDerivatives = Dynamic;
typedef OESTextureFloat = Dynamic;
typedef OESVertexArrayObject = Dynamic;
typedef Program = Dynamic;
typedef Renderbuffer = Dynamic;
typedef RenderingContext = Dynamic;
typedef Shader = Dynamic;
typedef ShaderPrecisionFormat = Dynamic;
typedef Texture = Dynamic;
typedef UniformLocation = Dynamic;
typedef VertexArrayObjectOES = Dynamic;

@:native("Float32Array")
extern class Float32Array implements ArrayAccess<Float> {
    public static var BYTES_PER_ELEMENT;
    public var length :Int;
    function new (length :Int) :Void;
    function subarray (begin :Int, end :Int) :Float32Array;
}

@:native("Uint16Array")
extern class Uint16Array implements ArrayAccess<Float> {
    public static var BYTES_PER_ELEMENT;
    public var length :Int;
    function new (length :Int) :Void;
    function subarray (begin :Int, end :Int) :Uint16Array;
}
