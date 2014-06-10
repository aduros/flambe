//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.asset.AssetPack;
import flambe.asset.File;

using flambe.util.Strings;

enum EmitterType
{
    Gravity; Radial;
}

/**
 * A particle system configuration, that can be used to create emitter sprites. The configuration is
 * loaded from a .pex file, authored in a tool such as Particle Designer.
 *
 * _NOTE_: There are some restrictions to keep in mind when using Particle Designer with Flambe:
 *
 * - Particle coloring is not supported.
 * - Only normal and additive blend modes are supported.
 *
 *
 * Also keep in mind that gratuitous particle systems are a great way to kill performance,
 * especially on mobile. Try to keep maxParticles as low as possible to achieve the desired effect.
 */
class EmitterMold
{
    public var texture :Texture;

    public var maxParticles :Int;

    public var type :EmitterType;

    // public var emitX :Float;
    public var emitXVariance :Float;

    // public var emitY :Float;
    public var emitYVariance :Float;

    public var alphaStart :Float;
    public var alphaStartVariance :Float;

    public var alphaEnd :Float;
    public var alphaEndVariance :Float;

    public var angle :Float;
    public var angleVariance :Float;

    public var duration :Float;

    public var gravityX :Float;
    public var gravityY :Float;

    public var maxRadius :Float;
    public var maxRadiusVariance :Float;

    public var minRadius :Float;

    public var lifespanVariance :Float;
    public var lifespan :Float;

    public var rotatePerSecond :Float;
    public var rotatePerSecondVariance :Float;

    public var rotationStart :Float;
    public var rotationStartVariance :Float;

    public var rotationEnd :Float;
    public var rotationEndVariance :Float;

    public var sizeStart :Float;
    public var sizeStartVariance :Float;

    public var sizeEnd :Float;
    public var sizeEndVariance :Float;

    public var speed :Float;
    public var speedVariance :Float;

    public var radialAccel :Float;
    public var radialAccelVariance :Float;

    public var tangentialAccel :Float;
    public var tangentialAccelVariance :Float;

    public var blendMode :BlendMode;

    /**
     * Creates an EmitterMold using files in an asset pack.
     * @param name The path to the particle system within the asset pack, excluding the .pex suffix.
     */
    public function new (pack :AssetPack, name :String)
    {
        _file = pack.getFile(name+".pex");
        var xml = Xml.parse(_file.toString());

        var blendFuncSource = 0;
        var blendFuncDestination = 0;

        // The basename of the pex file's path, where we'll find the textures
        var idx = name.lastIndexOf("/");
        var basePath = (idx >= 0) ? name.substr(0, idx+1) : "";

        for (element in xml.firstElement().elements()) {
            switch (element.nodeName.toLowerCase()) {
            case "texture":
                texture = pack.getTexture(basePath + element.get("name").removeFileExtension());
            case "angle":
                angle = getValue(element);
            case "anglevariance":
                angleVariance = getValue(element);
            case "blendfuncdestination":
                blendFuncDestination = Std.int(getValue(element));
            case "blendfuncsource":
                blendFuncSource = Std.int(getValue(element));
            case "duration":
                duration = getValue(element);
            case "emittertype":
                type = (Std.int(getValue(element)) == 0) ? Gravity : Radial;
            case "finishcolor":
                alphaEnd = getFloat(element, "alpha");
            case "finishcolorvariance":
                alphaEndVariance = getFloat(element, "alpha");
            case "finishparticlesize":
                sizeEnd = getValue(element);
            case "finishparticlesizevariance":
                sizeEndVariance = getValue(element);
            case "gravity":
                gravityX = getX(element);
                gravityY = getY(element);
            case "maxparticles":
                maxParticles = Std.int(getValue(element));
            case "maxradius":
                maxRadius = getValue(element);
            case "maxradiusvariance":
                maxRadiusVariance = getValue(element);
            case "minradius":
                minRadius = getValue(element);
            case "particlelifespan":
                lifespan = getValue(element);
            case "particlelifespanvariance":
                lifespanVariance = getValue(element);
            case "radialaccelvariance":
                radialAccelVariance = getValue(element);
            case "radialacceleration":
                radialAccel = getValue(element);
            case "rotatepersecond":
                rotatePerSecond = getValue(element);
            case "rotatepersecondvariance":
                rotatePerSecondVariance = getValue(element);
            case "rotationend":
                rotationEnd = getValue(element);
            case "rotationendvariance":
                rotationEndVariance = getValue(element);
            case "rotationstart":
                rotationStart = getValue(element);
            case "rotationstartvariance":
                rotationStartVariance = getValue(element);
            // case "sourceposition":
            case "sourcepositionvariance":
                emitXVariance = getX(element);
                emitYVariance = getY(element);
            case "speed":
                speed = getValue(element);
            case "speedvariance":
                speedVariance = getValue(element);
            case "startcolor":
                alphaStart = getFloat(element, "alpha");
            case "startcolorvariance":
                alphaStartVariance = getFloat(element, "alpha");
            case "startparticlesize":
                sizeStart = getValue(element);
            case "startparticlesizevariance":
                sizeStartVariance = getValue(element);
            case "tangentialaccelvariance":
                tangentialAccelVariance = getValue(element);
            case "tangentialacceleration":
                tangentialAccel = getValue(element);
            }
        }

        // Handle weird Particle Designer output for emitters with a duration
        if (lifespan <= 0) {
            lifespan = duration;
        }

        if (blendFuncSource == 1 && blendFuncDestination == 1) {
            blendMode = Add;
        } else if (blendFuncSource == 1 && blendFuncDestination == 771) {
            blendMode = null; // Normal
        } else if (blendFuncSource != 0 || blendFuncDestination != 0) {
            Log.warn("Unsupported particle blend functions", [
                "emitter", name, "source", blendFuncSource, "dest", blendFuncDestination ]);
        }
    }

    /**
     * Disposes the source .pex File used to create this EmitterMold. This can free up some memory,
     * if you don't intend to recreate this EmitterMold later from the same AssetPack.
     *
     * @returns This instance, for chaining.
     */
    public function disposeFiles () :EmitterMold
    {
        _file.dispose();
        return this;
    }

    /** Creates a new EmitterSprite using this mold. */
    public function createEmitter () :EmitterSprite
    {
        return new EmitterSprite(this);
    }

    private static function getFloat (xml :Xml, name :String) :Float
    {
        return Std.parseFloat(xml.get(name));
    }

    inline private static function getValue (xml :Xml) :Float
    {
        return getFloat(xml, "value");
    }

    inline private static function getX (xml :Xml) :Float
    {
        return getFloat(xml, "x");
    }

    inline private static function getY (xml :Xml) :Float
    {
        return getFloat(xml, "y");
    }

    private var _file :File;
}
