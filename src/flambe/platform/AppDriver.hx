//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.Entity;
import flambe.util.Promise;

interface AppDriver
{
    function init (root :Entity) :Void;

    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;

    function getStageWidth () :Int;
    function getStageHeight () :Int;

    function getStorage () :Storage;

    function getLocale () :String;

    function callNative (funcName :String, params :Array<Dynamic>) :Dynamic;

    function lockOrientation (orient :Orientation) :Void;
}
