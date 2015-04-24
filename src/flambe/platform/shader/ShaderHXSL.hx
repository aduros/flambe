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

/** Utility class for managing custom attributes */
class ShaderConst
{
    public function new()
    {
        _floatMap = new Map<String, Float>();
        _intMap = new Map<String, Int>();
        _vectorMap = new Map<String, Vector3D>();
    }

    /** Unility functions used to set custom attributes */
    public function setInt(name :String, value :Int) :Void
    {
        var location = _intMap.get(name);

        if(location != null)
        {
            location = value;
        }
    }

    public function setFloat(name :String, x :Float) :Void
    {
        var location = _floatMap.get(name);

        if(location != null)
        {
            location = x;
        }
    }

    public function setFloat2(name :String, x :Float, y :Float) :Void
    {
        var location = _vectorMap.get(name);

        if(location != null)
        {
            location.x = x;
            location.y = y;
        }
    }

    public function setFloat3(name :String,  x :Float, y :Float, z :Float) :Void
    {
        var location = _vectorMap.get(name);

        if(location != null)
        {
            location.x = x;
            location.y = y;
            location.z = z;
        }
    }

    public function setFloat4(name :String, x :Float, y :Float, z :Float, w :Float) :Void
    {
        var location = _vectorMap.get(name);

        if(location != null)
        {
            location.x = x;
            location.y = y;
            location.z = z;
            location.w = w;
        }
    }

    public function linkUniform1f(name :String, value :Float)
    {
        _floatMap.set(name, value);
    }

    public function linkUniform2f(name :String, value :Vector3D)
    {
        _vectorMap.set(name, value);
    }

    public function linkUnifor3f(name :String, value :Vector3D)
    {
        _vectorMap.set(name, value);
    }

    public function linkUniform4f(name :String, value :Vector3D)
    {
        _vectorMap.set(name, value);
    }

    public function linkUniformi(name :String, value :Int)
    {
        _intMap.set(name, value);
    }

    private var _floatMap   :Map<String, Float>;
    private var _intMap     :Map<String, Int>;
    private var _vectorMap  :Map<String, Vector3D>;
}