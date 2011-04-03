package flambe.platform;

import flambe.asset.AssetPackLoader;
import flambe.Entity;
import flambe.display.Texture;

interface AppDriver
{
    function init (root :Entity) :Void;

    function loadAssetPack (url :String) :AssetPackLoader;

    function getStageWidth () :Int;
    function getStageHeight () :Int;
}
