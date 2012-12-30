//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.asset.AssetPack;

using flambe.util.Strings;

class EmitterMold
{
    public var texture :Texture;

    public var maxParticles :Int;

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

    public function new (pack :AssetPack, name :String)
    {
        var blendFuncSource = 0;
        var blendFuncDestination = 0;

        var xml = Xml.parse(pack.getFile(name+".pex"));
        for (element in xml.firstElement().elements()) {
            switch (element.nodeName.toLowerCase()) {
            case "texture":
                texture = pack.getTexture(element.get("name").removeFileExtension());
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
                if (getValue(element) != 0) {
                    // TODO(bruno): Implement radial emitters
                    Log.warn("Radial emitters are not yet supported", ["emitter", name]);
                }
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
            // case "maxradius":
            //     maxRadius = getValue(element);
            // case "maxradiusvariance":
            //     maxRadiusVariance = getValue(element);
            // case "minradius":
            //     minRadius = getValue(element);
            case "particlelifespan":
                lifespan = getValue(element);
            case "particlelifespanvariance":
                lifespanVariance = getValue(element);
            case "radialaccelvariance":
                radialAccelVariance = getValue(element);
            case "radialacceleration":
                radialAccel = getValue(element);
            // case "rotatepersecond":
            // case "rotatepersecondvariance":
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

        if (blendFuncSource == 1 && blendFuncDestination == 1) {
            blendMode = Add;
        } else if (blendFuncSource == 1 && blendFuncDestination == 771) {
            // blendMode = Normal;
        } else if (blendFuncSource != 0 || blendFuncDestination != 0) {
            Log.warn("Unsupported particle blend functions", [
                "emitter", name, "source", blendFuncSource, "dest", blendFuncDestination ]);
        }
    }

    public function createSprite () :EmitterSprite
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
}
