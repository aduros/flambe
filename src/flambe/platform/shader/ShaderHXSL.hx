//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.shader;

import flash.display3D.textures.TextureBase;

/** Wrapper for custom shaders */
interface ShaderHXSL
{
    /** Bind texture function */
    public function bindTexture(texture :TextureBase) :Void;
}
