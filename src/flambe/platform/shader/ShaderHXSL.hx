//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import hxsl.Shader;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;

/** Wrapper for custom shaders */
interface ShaderHXSL
{
    public var shaderConst :ShaderConst;
    public function setTexture(texture :TextureBase) :Void;
}

class ShaderConst
{
    public function new()
    {
        _floatMap = new Map<String, Vector3D>();
        _intMap = new Map<String, Vector3D>();
        _textureMap = new Map<String, TextureBase>();
    }

    /** Unility functions used to set custom attributes */
    public function setInt(name :String, value :Int) :Void
    {

    }

    public function setFloat(name :String, x :Float) :Void
    {
        var value = _floatMap.get(name);

        if(value != null)
        {
            value.x = x;
        }
    }

    public function setFloat2(name :String, x :Float, y :Float) :Void
    {
        var value = _floatMap.get(name);

        if(value != null)
        {
            value.x = x;
            value.y = y;
        }
    }

    public function setFloat3(name :String,  x :Float, y :Float, z :Float) :Void
    {
        var value = _floatMap.get(name);

        if(value != null)
        {
            value.x = x;
            value.y = y;
            value.z = z;
        }
    }

    public function setFloat4(name :String, x :Float, y :Float, z :Float, w :Float) :Void
    {
        var value = _floatMap.get(name);

        if(value != null)
        {
            value.x = x;
            value.y = y;
            value.z = z;
            value.w = w;
        }
    }

    public function linkUniformf(name :String, value :Vector3D)
    {
        _floatMap.set(name, value);
    }

    private var _floatMap :Map<String, Vector3D>;
    private var _intMap :Map<String, Vector3D>;
    private var _textureMap :Map<String, TextureBase>;
}