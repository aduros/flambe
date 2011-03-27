package flambe.platform.amity;

import flambe.asset.AssetPackLoader;
import flambe.display.Texture;
import flambe.Entity;
import flambe.FrameVisitor;
import flambe.platform.AppDriver;

class AmityAppDriver
    implements AppDriver
{
    public function new ()
    {
    }

    public function init (root :Entity)
    {
        var frameVisitor = new FrameVisitor(new AmityDrawingContext());
        (untyped __amity).onEnterFrame = function (dt :Int) {
            frameVisitor.init(dt);
            root.visit(frameVisitor);
        };
#if debug
        // Redirect traces to Amity
        haxe.Log.trace = (untyped __amity).log;
#end
    }

    public function createTexture (assetName :String) :Texture
    {
        return (untyped __amity).createTexture(assetName);
    }

    public function loadAssetPack (url :String) :AssetPackLoader
    {
        return null; // TODO
    }
}
